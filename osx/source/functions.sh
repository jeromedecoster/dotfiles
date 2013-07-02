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
    [[ "$1" != '-a' && "$1" != '-b' && "$1" != '-d' && "$1" != '-i' && "$1" != '-u' ]] && usage=1
    if [[ "$usage" -ne 1 ]]; then
        local BLU="\033[0;34m"
        local RES="\033[0m"

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
            echo -e "Removed $BLU~/.inputrc$RES"
            echo -e "Replaced $BLU~/.gitconfig$RES"
            echo -e "Replaced $BLU~/.bash_profile$RES"
        fi

        # remove homebrew and formulas
        if [[ "$1" == '-b' || "$1" == '-a' ]]; then
            local brew_path=$(type -P brew)
            if [[ "$brew_path" && -x "$brew_path" ]]; then
                brew uninstall tree &>/dev/null
                brew uninstall man2html &>/dev/null
                brew uninstall phantomjs &>/dev/null
                echo -e "Removed ${BLU}homebrew formulas$RES"
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
                echo -e "Removed ${BLU}homebrew$RES"
            fi
        fi

        # remove ~/.dotfiles directory
        if [[ "$1" == '-d' || "$1" == '-a' ]]; then
            rm -rf ~/.dotfiles
            echo -e "Removed $BLU~/.dotfiles$RES"
        fi

        if [[ "$1" == '-i' ]]; then
            bash -c "$(curl -fsSL raw.github.com/jeromedecoster/dotfiles/master/osx/install)" && source ~/.bash_profile
        fi
    else
        # write the usage message in the stderr and exit 1
        local msg=$(cat <<EOF
usage: undot [-abdiu]       # requires one option selected
option: -a remove all
        -b remove homebrew and formulas
        -d remove ~/.dotfiles directory
        -i launch install script
        -u remove user files
EOF)
        $(echo -e "$msg" >&2; exit 1)
    fi
}

# kaf, 'kill all finder'
# closes all the opened Finder windows and set the view
# of the next opened window to column view
function kaf() {
    arch -i386 osascript <<EOF
    tell application "Finder"
        set lst to windows as list
        set cnt to count of lst
        if cnt > 1 then
            repeat with e in (items 2 thru cnt of lst)
                close e
            end repeat
        end if
        if cnt > 0 then
            set e to item 1 of lst
            set current view of e to column view
            close e
        end if
        log ""
    end tell
EOF
}

# kof, 'kill other finder'
# keeps the frontmost window of the Finder as is
# and closes all the others
function kof() {
    arch -i386 osascript <<EOF
    tell application "Finder"
        set lst to windows as list
        set cnt to count of lst
        if cnt > 1 then
            repeat with e in (items 2 thru cnt of lst)
                close e
            end repeat
        end if
        log ""
    end tell
EOF
}

# kat, 'kill all terminal'
# closes all the opened Terminal windows
function kat() {
    arch -i386 osascript <<EOF
    if application "Terminal" is running then
        tell application "Terminal"
            set lst to windows as list
            repeat with e in lst
                close e
            end repeat
        end tell
    end if
EOF
}

# kof, 'kill other terminal'
# keeps the current Terminal window/tab and
# closes all the others
function kot() {
    arch -i386 osascript <<EOF
    if application "Terminal" is running then
        tell application "Terminal"
            set lst to windows as list
            set cnt to count of lst
            if cnt > 1 then
                repeat with e in (items 2 thru cnt of lst)
                    close e
                end repeat
            end if
            if cnt > 0 then
                activate
                set lst to tabs of item 1 of lst
                set cnt to count of lst
                if cnt > 1 then
                    repeat with i from 1 to count lst
                        if selected of item i of lst then
                            set idx to i
                            exit repeat
                        end if
                    end repeat
                    repeat with i from 1 to cnt
                        -- revese idx because repeat with can only increase values
                        set rev to (cnt + 1 - i)
                        if not rev = idx then
                            set selected of item rev of lst to true
                            -- keystroke hack because there is no api to close terminal tab
                            tell application "System Events" to tell process "Terminal.app" to keystroke "w" using command down
                        end if
                    end repeat
                end if
            end if
        end tell
    end if
EOF
}
