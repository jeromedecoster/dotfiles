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

# uninstall a part or all of the dotfiles components
# usefull for the development and tests
function undot() {
    local usage
    [[ $# -ne 1 ]] && usage=1
    [[ "$1" != '-a' && "$1" != '-b' && "$1" != '-d' && "$1" != '-u' ]] && usage=1
    if [[ "$usage" -ne 1 ]]; then
        # remove the user files, leaves a minimum content
        if [[ "$1" == '-u' || "$1" == '-a' ]]; then
            rm -f ~/.inputrc
            local cnt=$(cat <<EOF
[user]
    name = jerome@work
    email = github@jeromedecoster.com
EOF)
            echo -e "$cnt" > ~/.gitconfig
            local cnt=$(cat <<EOF
# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
EOF)
            echo -e "$cnt" > ~/.bash_profile
        fi

        # remove homebrew and formulas
        if [[ "$1" == '-b' || "$1" == '-a' ]]; then
            local brew_path=$(type -P brew)
            if [[ "$brew_path" && -x "$brew_path" ]]; then
                brew uninstall tree &>/dev/null
                brew uninstall man2html &>/dev/null
                brew uninstall phantomjs &>/dev/null
                # brew prune: remove dead symblink
                brew prune 1>/dev/null
                tmp=$(brew --prefix)
                rm -rf $tmp/bin/brew
                rm -rf $tmp/Library/brew.rb
                rm -rf $tmp/Contributions
                rm -rf $tmp/Cellar
                rm -rf $tmp/Library
                rm -rf $tmp/share/man/man1/brew.1
                rm -rf $tmp/.git
            fi
        fi

        # remove ~/.dotfiles directory
        if [[ "$1" == '-d' || "$1" == '-a' ]]; then
            rm -rf ~/.dotfiles
        fi
    else
        # write the usage message in the stderr and exit 1
        local msg=$(cat <<EOF
usage: undot [-abdu]       # requires one option selected
option: -a remove all
        -b remove homebrew and formulas
        -d remove ~/.dotfiles directory
        -u remove user files
EOF)
        $(echo -e "$msg" >&2; exit 1)
    fi
}
