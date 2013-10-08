
dot() {
  # inner functions
  function update() {
    bash -c "$(curl -fsSL raw.github.com/jeromedecoster/dotfiles/master/osx/install)" && source ~/.bash_profile
  }
  function homebrew() {
    local path=`type -P brew`
    if [[ -n "$path" && -x "$path" ]]; then
      brew ls -1 2>/dev/null | while read name; do
        brew uninstall "$name" &>/dev/null
        echo -e "remove $STDOUT_HIGHLIGHT$name$COL_RES homebrew formula"
      done

      # brew prune: remove dead symblink
      brew prune 1>/dev/null
      path=$(brew --prefix)
      path=/usr/local/homebrew
      if [[ -n "$path" ]]; then
        rm -rf $path/bin/brew
        rm -rf $path/Library/brew.rb
        rm -rf $path/Contributions
        rm -rf $path/Cellar
        rm -rf $path/Library
        rm -rf $path/share/man/man1/brew.1
        rm -rf $path/.git
        # extra remove
        rm -rf $path/.gitignore
        rm -rf $path/*.md
        rm -rf $path/etc/openssl
        rm -rf $path/lib/python2.7/site-packages
        if [[ -n `type -P crap` ]]; then
          crap -c $path | while read l; do rm -rf "$l"; done
          crap -d $path | while read l; do rm -rf "$l"; done
        fi
        [[ -z `ls -1 $path` ]] && rm -rf $path
        echo -e "remove ${STDOUT_HIGHLIGHT}homebrew$COL_RES"
      fi
    fi
  }
  function extensions() {
    # uninstall chrome extensions
    if [[ -d '/Applications/Google Chrome.app' ]]; then
      # chrome must be closed to unsintall extension
      # check if chrome is listed in active processes and exclude this commandline call from the result
      if [[ -n `ps -e | grep "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" | grep -v "grep"` ]]; then
        killall "Google Chrome"
      fi

      while read id name; do
        if [[ -d ~/Library/Application\ Support/Google/Chrome/Default/Extensions/$id ]]; then
          # waits 2 seconds to be sure chrome is closed
          sleep 2
          open -a "Google Chrome" --args --uninstall-extension=$id
          echo -e "remove $STDOUT_HIGHLIGHT$name$COL_RES chrome extension"
        fi
      done < <(cat <<EOF
cfhdojbkjhnklbpkdaibdccddilifddb Adblock Plus
nipdlgebaanapcphbcidpmmmkcecpkhg PrettyPrint
bcjindcccaagfpapjjmafapmmgkkhgoa JSON Formatter
jnihajbhpnppcggbcgedagnkighmdlei LiveReload
EOF)
    fi

    # uninstall firefox extensions
    if [[ -d '/Applications/Firefox.app' ]]; then
      # firefox must be closed to unsintall extension
      # check if firefox is listed in active processes and exclude this commandline call from the result
      if [[ -n `ps -e | grep "/Applications/Firefox.app/Contents/MacOS/firefox" | grep -v "grep"` ]]; then
        # we can't use the killall way to close firefox. It works, but the next time you will
        # launch firefox it will display the alert page 'do you want to restore the previous tabs?'
        local cmd
        arch -i386 pwd &>/dev/null
        [[ $? -eq 0 ]] && cmd="arch -i386 osascript" || cmd="osascript"
        eval "$cmd" <<EOF
tell application "Firefox" to quit
delay 1
EOF
      fi

      local profile=`find ~/Library/Application\ Support/Firefox/Profiles -type d -depth 1 -name '*.default'`
      if [[ -n "$profile" ]]; then
        while read xpi name; do
          if [[ -f "$profile/extensions/$xpi" ]]; then
            rm -f "$profile/extensions/$xpi"
            echo -e "remove $STDOUT_HIGHLIGHT$name$COL_RES firefox extension"
          fi
        done < <(cat <<EOF
{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi Adblock Plus
firebug@software.joehewitt.com.xpi Firebug
netexport@getfirebug.com.xpi Net Export
{DDC359D1-844A-42a7-9AA1-88A850A938A8}.xpi DownThemAll
livereload@livereload.com.xpi LiveReload
EOF)
      fi
    fi
  }
  function user_files() {
    if [[ -f ~/.inputrc ]]; then
      rm -f ~/.inputrc
      echo -e "remove ${STDOUT_HIGHLIGHT}~/.inputrc$COL_RES"
    fi

    if [[ -f ~/.bash_profile ]]; then
      rm -f ~/.bash_profile
      echo -e "remove ${STDOUT_HIGHLIGHT}~/.bash_profile$COL_RES"
    fi

    if [[ -f ~/.gitconfig ]]; then
      local name=`git config --global user.name 2>/dev/null`
      local email=`git config --global user.email 2>/dev/null`
      rm -f ~/.gitconfig
      [[ -n "$name" ]] && git config --global user.name "$name"
      [[ -n "$email" ]] && git config --global user.email "$email"
      echo -e "replace ${STDOUT_HIGHLIGHT}~/.gitconfig$COL_RES"
    fi
  }
  function prompt_remove() {
    echo
    echo '  b) homebrew and formulas'
    echo '  e) browsers extensions'
    echo '  u) user files'
    echo
    while true; do
      echo -n "what do you want remove? [beu] : "
      read r
      r=$(echo "$r" | tr '[A-Z]' '[a-z]')
      case "$r" in
        b) homebrew; break;;
        e) extensions; break;;
        u) user_files; break;;
      esac
    done
  }
  function prompt_main() {
    echo
    echo '  u) update dotfiles'
    echo '  r) remove some installed components'
    echo
    while true; do
      echo -n "select an action [rU] : "
      read r
      r=$(echo "$r" | tr '[A-Z]' '[a-z]')
      case "$r" in
           r) clear && prompt_remove; break;;
        u|'') update; break;;
      esac
    done
  }

  prompt_main
  unset -f update
  unset -f homebrew
  unset -f extensions
  unset -f user_files
  unset -f prompt_remove
  unset -f prompt_main
}
