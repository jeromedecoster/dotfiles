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

# uninstall a part or all of the dotfiles components
# usefull for the development and tests
function undot() {
    local usage
    [[ $# -ne 1 ]] && usage=1
    case "$1" in
        -a|-b|-d|-e|-i|-n|-u) ;;
                           *) usage=1 ;;
    esac

    if [[ "$usage" -ne 1 ]]; then
        local BLU="\033[0;34m"
        local RES="\033[0m"

        # remove the user files, leaves a minimum content
        if [[ "$1" = '-u' || "$1" = '-a' ]]; then
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
        if [[ "$1" = '-b' || "$1" = '-a' ]]; then
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
        if [[ "$1" = '-d' || "$1" = '-a' ]]; then
            rm -rf ~/.dotfiles
            echo -e "Removed $BLU~/.dotfiles$RES"
        fi

        # remove browsers extensions
        if [[ "$1" = '-e' || "$1" = '-a' ]]; then
            local process names ids xpis
            # uninstall chrome extensions
            if [[ -d '/Applications/Google Chrome.app' ]]; then
                # chrome must be closed to unsintall extension, check if chrome is listed in active processes
                process="$(ps -e | grep "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")"
                # exclude this commandline call from the result
                if [[ $(echo "$process" | grep -v -c "grep") -ne 0 ]]; then
                    killall "Google Chrome"
                fi

                # uninstall the extensions in arrays
                names=('Adblock Plus' PrettyPrint 'JSON Formatter' LiveReload)
                ids=(cfhdojbkjhnklbpkdaibdccddilifddb nipdlgebaanapcphbcidpmmmkcecpkhg \
                     bcjindcccaagfpapjjmafapmmgkkhgoa jnihajbhpnppcggbcgedagnkighmdlei)

                for (( i=0; i<${#names[@]}; i=i+1 )); do
                    if [[ -d ~/Library/Application\ Support/Google/Chrome/Default/Extensions/"${ids[i]}" ]]; then
                        # waits 2 seconds to be sure chrome is closed
                        sleep 2
                        open -a "Google Chrome" --args --uninstall-extension="${ids[i]}"
                        echo -e "Removed ${BLU}${names[i]}$RES chrome extension"
                    fi
                done
                unset i
            fi
            # uninstall firefox extensions
            if [[ -d '/Applications/Firefox.app' ]]; then
                # firefox must be closed to unsintall extension, check if firefox is listed in active processes
                process="$(ps -e | grep "/Applications/Firefox.app/Contents/MacOS/firefox")"
                # exclude this commandline call from the result
                if [[ $(echo "$process" | grep -v -c "grep") -ne 0 ]]; then
                    # we can't use the killall way to close firefox. It works, but the next time you will
                    # launch firefox it will display the alert page 'do you want to restore the previous tabs?'
                    # there is also a strange applescript problem: if we want check if firefox is already running
                    # or not, all the possible/usual ways to test it will not works because each test starts firefox
                    # if it is currently closed. So we need to check it with 'ps -e'
                    local cmd
                    arch -i386 pwd &>/dev/null
                    [[ $? -eq 0 ]] && cmd="arch -i386 osascript" || cmd="osascript"
                    eval "$cmd" <<EOF
        tell application "Firefox" to quit
        delay 1
EOF
                fi
                local profile="$(find ~/Library/Application\ Support/Firefox/Profiles -type d -depth 1 -name '*.default')"
                if [[ "$profile" ]]; then

                    # uninstall the extensions in arrays
                    names=('Adblock Plus' Firebug 'Net Export' DownThemAll LiveReload)
                    xpis=('{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi' 'firebug@software.joehewitt.com.xpi' \
                          'netexport@getfirebug.com.xpi' '{DDC359D1-844A-42a7-9AA1-88A850A938A8}.xpi' \
                          'livereload@livereload.com.xpi')

                    for (( i=0; i<${#names[@]}; i=i+1 )); do
                        if [[ -f "$profile/extensions/${xpis[i]}" ]]; then
                            rm -f "$profile/extensions/${xpis[i]}"
                            echo -e "Removed ${BLU}${names[i]}$RES firefox extension"
                        fi
                    done
                fi
            fi
        fi

        # remove nodejs
        if [[ "$1" = '-n' || "$1" = '-a' ]]; then
            function owner() {
                [[ "$(stat -f %u $1)" != "$(id -u)" ]] && echo 1
            }
            function prompt_chown() {
                local BLU="\033[0;34m"
                local RED="\033[0;31m"
                local RES="\033[0m"
                echo -e "You are not the owner of the directory ${BLU}$1$RES"
                while true; do
                    echo -e -n "Do you want to ${RED}sudo chown$RES this directory to remove it? [Yn]: "
                    read r
                    r=$(echo "$r" | tr '[A-Z]' '[a-z]')
                    case "$r" in
                        y|n) selected="$r"; break ;;
                         '') selected='y';  break ;;
                    esac
                done
            }

            # special folders, not owned by the user

            local dir=/usr/local/lib/node_modules
            if [[ -d $dir ]]; then
                if [[ `owner $dir` -eq 1 ]]; then
                    # check if a sudo is needed to chown. if admin or
                    # already sudoed, no need to prompt the user
                    sudo -n true 2>/dev/null
                    # if a sudo is required, the command above will exit 1
                    if [[ $? -ne 0 ]]; then
                        prompt_chown $dir
                        # prompt_chown set the var $selected to 'y' if the user accepct the sudo
                        if [[ "$selected" = 'y' ]]; then
                            # recursive chown required
                            sudo chown -R `whoami` $dir
                            rm -rf $dir
                        fi
                        unset selected
                    # sudo is not required, so it is not needed to prompt the user
                    # but chown must be used with sudo, so we write it below, but not password will be asked
                    else
                        # recursive chown required
                        sudo chown -R `whoami` $dir
                        rm -rf $dir
                    fi
                # the user is the owner, just remove it
                else
                    rm -rf $dir
                fi
            fi

            local dir=/usr/local/lib/dtrace
            local file=$dir/node.d
            if [[ -d $dir ]]; then
                if [[ `owner $dir` -eq 1 ]]; then
                    # check if a sudo is needed to chown. if admin or
                    # already sudoed, no need to prompt the user
                    sudo -n true 2>/dev/null
                    # if a sudo is required, the command above will exit 1
                    if [[ $? -ne 0 ]]; then
                        prompt_chown $dir
                        # prompt_chown set the var $selected to 'y' if the user accepct the sudo
                        if [[ "$selected" = 'y' ]]; then
                            sudo chown `whoami` $dir
                            rm -rf $file
                        fi
                        unset selected
                    # sudo is not required, so it is not needed to prompt the user
                    # but chown must be used with sudo, so we write it below, but not password will be asked
                    else
                        sudo chown `whoami` $dir
                        rm -rf $file
                    fi
                # the user is the owner, just remove it
                else
                    rm -rf $file
                fi
            fi
            unset owner
            unset prompt_chown

            rm -f /usr/local/bin/n
            rm -rf /usr/local/n
            rm -rf ~/.nave

            rm -f /usr/local/bin/node
            rm -f /usr/local/bin/node-waf
            rm -f /usr/local/bin/npm
            rm -rf /usr/local/lib/node

            rm -rf /usr/local/include/node
            rm -rf /usr/local/include/node_modules
        fi

        if [[ "$1" = '-i' ]]; then
            bash -c "$(curl -fsSL raw.github.com/jeromedecoster/dotfiles/master/osx/install)" && source ~/.bash_profile
        fi
    else
        # write the usage message in the stderr and exit 1
        local msg=$(cat <<EOF
usage: undot [-abdeiu]       # requires one option selected
option: -a remove all except the browser extensions
        -b remove homebrew and formulas
        -d remove ~/.dotfiles directory
        -e remove browsers extensions
        -i launch install script
        -n remove nodejs
        -u remove user files
EOF)
        $(echo -e "$msg" >&2; exit 1)
    fi
}

# kaf, 'kill all finder'
# closes all the opened Finder windows and set the view
# of the next opened window to column view
function kaf() {
  local cmd
  arch -i386 pwd &>/dev/null
  [[ $? -eq 0 ]] && cmd="arch -i386 osascript" || cmd="osascript"
  eval "$cmd" <<EOF
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
  local cmd
  arch -i386 pwd &>/dev/null
  [[ $? -eq 0 ]] && cmd="arch -i386 osascript" || cmd="osascript"
  eval "$cmd" <<EOF
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
  local cmd
  arch -i386 pwd &>/dev/null
  [[ $? -eq 0 ]] && cmd="arch -i386 osascript" || cmd="osascript"
  eval "$cmd" <<EOF
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
  local cmd
  arch -i386 pwd &>/dev/null
  [[ $? -eq 0 ]] && cmd="arch -i386 osascript" || cmd="osascript"
  eval "$cmd" <<EOF
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

# dirty hack to disable homebrew warning 'It appears you have MacPorts or Fink installed'
# when you install or upgrade a formula
brew() {
  if [[ `type -P brew` ]]; then
    local path=`type -P brew`

    # if 'brew install' or 'brew upgrade' are invoked
    if [[ $1 == 'install' || $1 == 'upgrade' ]]; then
      local cwd="$(pwd)"
      local prefix=`eval "$path --prefix"`
      local file=`echo $prefix/Library/Homebrew/cmd/install.rb`

      # if uncommented line found in Homebrew/cmd/install.rb to check macports, comment it
      if [[ -f $file && `egrep '^[[:blank:]]+check_macports$' $file` ]]; then
        local tmp=`mktemp /tmp/homebrew.XXXXX`
        sed -E '/^[[:blank:]]+check_macports$/ s/^/#/' $file > $tmp && mv $tmp $file
        rm -f $tmp

        # execute brew
        eval "$path $@"

        # then revert the commented file
        cd "$prefix"
        git checkout $file
        cd "$cwd"
      # fallback, but normally you should never go here
      else
        eval "$path $@"
      fi
    # other commands
    else
      eval "$path $@"
    fi
  else
    `echo 'brew: command not found' >&2; exit 127`
  fi
}
