# t is the new touch, yo
# touch multiple files at once. It also create folders recursively if necessary
# example, create 2 files in the pwd: t file1 file2
# example, create 2 files in path/to and in the pwd: t path/to/file1 file2
function t() {
    if [[ $# -gt 0 ]]; then
        for arg in "$@"; do
            fol=$(
                echo "$arg" | awk 'BEGIN {FS="/"} \
                    {a="";                      \
                    for(i=1;i<NF;i++) a=a"/"$i; \
                    print substr(a,2)}'
                )
            [[ -n "$fol" ]] && mkdir -p "$fol"
            touch "$arg"
            unset arg
        done
    else
        # write the usage message in the stderr and
        # return the exitcode 1 without quit the terminal (yeah baby)
        # echo $? after the usage message will write 1
        local msg=$(cat <<EOF
usage: t file [file] ...
       t path/to/file [file] ...
EOF)
        $(echo -e "$msg" >&2; exit 1)
    fi
}

# tx is an evolution of t
# touch multiple files at once and chmod them as executable for all users
# adds a bash shebang if the file is created
# otherwise adds a ruby shebang if the option -r is set
# example, create a bash executable: tx file1
# example, create a ruby executable: tx -r path/to/file2
function tx() {
    if [[ $# -gt 0 ]]; then
        local bang="#!/bin/bash"
        if [[ $1 == '-r' ]]; then
            bang="#!/usr/bin/env ruby"
            shift
        fi
        for arg in "$@"; do
            fol=$(
                    echo "$arg" | awk 'BEGIN {FS="/"} \
                    {a="";                      \
                    for(i=1;i<NF;i++) a=a"/"$i; \
                    print substr(a,2)}'
                )
            [[ -n "$fol" ]] && mkdir -p "$fol"
            if [[ -r "$arg" ]]; then
                touch "$arg"
            else
                echo -e "$bang" > "$arg"
            fi
            chmod a+x "$arg"
        done
        unset arg
    else
        # write the usage message in the stderr and
        # return the exitcode 1 without quit the terminal
        # echo $? after the usage message will write 1
        local msg=$(cat <<EOF
usage: tx [-r] file [file] ...
       tx [-r] path/to/file [file] ...
option: -r write a ruby shebang
EOF)
        $(echo -e "$msg" >&2; exit 1)
    fi
}

# mk create one or more directories and enter the last (cd)
# example, create and enter the folder 'yo': mk yo
# example, create 'yo' and 'mama' and enter 'mama': mk yo mama
function mk() {
    if [[ $# -gt 0 ]]; then
        mkdir -p "$@"
        cd "${@: -1}"
    else
        # write the usage message in the stderr and
        # return the exitcode 1 without quit the terminal
        # echo $? after the usage message will write 1
        $(echo "usage: mk directory [directory] ..." >&2; exit 1)
    fi
}

# switch the prompt
# example, switch to the basic prompt: prompt
# example, switch to the advanced prompt: prompt -a
function prompt() {
    if [[ $1 == '-a' ]]; then
        PROMPT_COMMAND="prompt_advanced"
    else
        PROMPT_COMMAND="prompt_basic"
    fi
}

# return the local repository root of a svn repo
# return nothing if not inside a svn directory
# example, inside the folder /Volumes/Documents/work/projectname/trunk/home/css/
# execute 'svnroot' return: /Volumes/Documents/work/projectname/trunk
# svnroot accept also 1 argument (a path to a directory or a file)
# execute 'svnroot /Volumes/Documents/work/projectname/trunk/home/css/style.css'
# or execute 'svnroot /Volumes/Documents/work/projectname/trunk/home/css'
# both will return: /Volumes/Documents/work/projectname/trunk
# note: Ruby or Python must be installed
function svnroot() {
    local ruby=$(type -P ruby)
    local python=$(type -P python)
    if [[ "$ruby" || "$python" ]]; then
        if [[ $# -le 1 ]]; then
            local folder
            # without argument, folder is the pwd with a trailing '/'
            if [[ $# -eq 0 ]]; then
                folder="$(pwd)/"
            else
                # if the argument is a directory, just add a trailing '/'
                # note: 2 trailing slash doesn't break things
                if [[ -d "$1" ]]; then
                    folder="$1/"
                # if the argument is a file, get the parent directory and
                # add a trailing '/'
                elif [[ -f "$1" ]]; then
                    folder="$(dirname "$1")/"
                fi
            fi
            if [[ "$folder" ]]; then
                local info="$(svn info "$folder" 2> /dev/null)"
                if [[ "$info" ]]; then
                    local uuid=$(echo "$info" | awk '/^Repository UUID:/ { print $3 }')
                    # local folder=""
                    while true; do
                        info=$(svn info "$folder../" 2> /dev/null)
                        if [[ "$info" && $(echo "$info" \
                                           | awk '/^Repository UUID:/ { print $3 }') == "$uuid" ]]; then
                            folder="$folder../"
                            continue
                        else
                            if [[ "$ruby" ]]; then
                                echo $(ruby -e "print File.expand_path '$folder'")
                            else
                                echo $(python -c "import os;print(os.path.abspath('$folder'))")
                            fi
                            break
                        fi
                    done
                fi
            # the variable folder is not defined if the argument $1
            # is not a real directory or a real file
            # write the error message in the stderr and
            # return the exitcode 1 without quit the terminal
            # echo $? after the error message will write 1
            else
                $(echo -e "error: the path '$1' does not exist" >&2; exit 1)
            fi
        else
            # write the usage message in the stderr and
            # return the exitcode 1 without quit the terminal
            # echo $? after the usage message will write 1
            local msg=$(cat <<EOF
usage: svnroot
       svnroot path/to/folder
       svnroot path/to/file
EOF)
            $(echo -e "$msg" >&2; exit 1)
        fi
    else
        # write the error message in the stderr and
        # return the exitcode 1 without quit the terminal
        # echo $? after the error message will write 1
        $(echo -e "error: Ruby or Python is required" >&2; exit 1)
    fi
}

# remove all crap files in a directory and sub-directories
# files: .DS_Store .Spotlight-V100 desktop.ini Thumbs.db
# if the directory is a sub-directory of a git or svn repo
# will try to remove all crap files from the local root of
# this repository
# example: execute 'crap' remove all files in the pwd
# example: execute 'crap path/to/folder' remove all files in this folder
function crap() {
    local folder cur error
    cur=$(pwd)

    if [[ $# -eq 1 ]]; then
        # if the first argument is a directory, cd into it
        if [[ -d "$1" ]]; then
            cd "$1"
        # otherwise define the variable error, everything
        # will be stopped and usage message will be shown
        else
            error=1
        fi
    fi

    # if no argument or error is still undefined (means 1 argument
    # with a real directory), define the variable folder
    if [[ $# -eq 0 || ! "$error" ]]; then
        # if git directory, locate the root repo directory
        if [[ "$(git status 2>/dev/null)" ]]; then
            folder=$(git rev-parse --show-toplevel)
        else
            # if svn directory, try to locate the root repo directory
            if [[ "$(svn info . 2> /dev/null)" ]]; then
                if [[ "$(type -P ruby)" || "$(type -P python)" ]]; then
                    folder=$(svnroot)
                else
                    folder=$(pwd)
                fi
            # otherwise take the pwd
            else
                folder=$(pwd)
            fi
        fi
    fi

    cd "$cur"

    # if the variable folder is defined, find crap files
    if [[ "$folder" ]]; then
        local files=$(find "$folder" -type f -name '.DS_Store'   -o -name '.Spotlight-V100' \
                                  -o -name 'desktop.ini' -o -name 'Thumbs.db' 2>/dev/null)

        # transform string variable $files in array variable $lines
        local old_IFS=$IFS
        IFS=$'\n'
        local lines=($(echo "$files"))
        IFS=$old_IFS
        for i in "${lines[@]}"; do
            echo -e "Delete \033[0;34m$i\033[0m" && rm -f "$i"
        done
        unset i
    # the variable folder is undefined, show the usage message
    else
        # write the usage message in the stderr and
        # return the exitcode 1 without quit the terminal
        # echo $? after the usage message will write 1
        local msg=$(cat <<EOF
usage: crap
       crap path/to/folder
EOF)
        $(echo -e "$msg" >&2; exit 1)
    fi
}