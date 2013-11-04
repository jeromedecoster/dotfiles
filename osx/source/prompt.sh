# display svn infos when inside a repository directory
__prompt_svn() {
  local info=`svn info 2>/dev/null`
  # if info is empty, not inside a svn repo
  [[ -z $info ]] && return

  local files filter
  filter="DocumentRevisions-V100|DS_Store|fseventsd|git|Spotlight-V100|svn"
  filter="$filter|TheVolumeSettingsFolder|TemporaryItems|Trash|Trashes"
  # list all files in this directory, exclude some crap files and directories
  files=`ls -A1 | egrep -v "\.($filter)$"`

  local rev
  # if no file in this svn directory, return a basic prompt info
  # with the last change revision of the current directory
  if [[ -z $files ]]; then
    rev=`echo "$info" | grep "^Last Changed Rev" | cut -d ' ' -f 4`
    echo "[svn r$rev]"
    return
  fi

  local status mod mis unt min max
  status=`svn status`
  # status is not empty if files are modified, missing or untracked
  if [[ -n $status ]]; then
    # check for modified, missing or untracked files
    # each variables contains the count of found files (0 or more)
    mod=`echo "$status" | grep -c "^[ADM]"`
    mis=`echo "$status" | grep -c "^\!"`
    unt=`echo "$status" | grep -c "^\?"`
  fi

  # collect revision of each files and set min and max revision
  for f in $files; do
    info=`svn info $f 2>/dev/null`
    # if info, means this file is managed by svn
    if [[ -n $info ]]; then
      # revision of this file
      rev=`echo "$info" | grep "^Last Changed Rev" | cut -d ' ' -f 4`
      # variable is setted
      if [[ -n $min ]]; then
        [[ $rev -lt $min ]] && min=$rev
        [[ $rev -gt $max ]] && max=$rev
      # variable is not yet setted
      else
        # init vars
        min=$rev
        max=$rev
      fi
    fi
  done

  # if no modified, missing or untracked files
  if [[ $mod -eq 0 && $mis -eq 0 && $unt -eq 0 ]]; then
    [[ $min -lt $max ]] && echo "[svn r$min-r$max]" || echo "[svn r$max]"
  # otherwise, more complex prompt with warn
  else
    local warn
    [[ $mod -gt 0 ]] && warn="${warn}-${PROMPT_MODIFIED}mod${COL_RES}"
    # missing file take the same color than modified file
    [[ $mis -gt 0 ]] && warn="${warn}-${PROMPT_MODIFIED}mis${COL_RES}"
    [[ $unt -gt 0 ]] && warn="${warn}-${PROMPT_UNTRACKED}unt${COL_RES}"
    # if warn starts with a dash, remove it
    [[ ${warn:0:1} == "-" ]] && warn=${warn:1}
    echo "[svn r$min-r$max:$warn]"
  fi
}

# display git infos when inside a repository directory
__prompt_git() {
  local status=`git status 2>/dev/null`
  # if status is empty, not inside a git repo
  [[ -z $status ]] && return

  local output
  # if initial commit, branch status is 'init'
  if [[ -n `echo "$status" | grep "^# Initial commit"` ]]; then
    output="${PROMPT_BRANCH}init${COL_RES}"
  else
    output=`echo "$status" | grep '^# On branch' | cut -f 4 -d ' '`
    output="${PROMPT_BRANCH}$output${COL_RES}"
  fi

  local sta mod unt
  # check for staged, modified or untracked files
  sta=`echo "$status" | grep "^# Changes to be committed"`
  mod=`echo "$status" | grep "^# Changes not staged for commit"`
  unt=`echo "$status" | grep "^# Untracked files"`

  local vcs=
  [[ $PROMPT_VCS -eq 1 ]] && vcs='git '

  # if no staged, modified or untracked files
  if [[ -z $sta && -z $mod && -z $unt ]]; then
    echo "[$vcs$output]"
  # otherwise, more complex prompt with warn
  else
    [[ -n $sta ]] && warn="${PROMPT_STAGED}sta${COL_RES}"
    [[ -n $mod ]] && warn="${warn}-${PROMPT_MODIFIED}mod${COL_RES}"
    [[ -n $unt ]] && warn="${warn}-${PROMPT_UNTRACKED}unt${COL_RES}"
    # if warn starts with a dash, remove it
    [[ ${warn:0:1} == "-" ]] && warn=${warn:1}
    echo "[$vcs$output:$warn]"
  fi
}

# the current directory path displayed in the advanced prompt
__prompt_path() {
  local tmp
  # pwd is ~
  if [[ $PWD == $HOME ]]; then
    echo "[${PROMPT_PATH}~${COL_RES}]"
    return
  # pwd is inside ~
  elif [[ $HOME == ${PWD:0:${#HOME}} ]]; then
    tmp="~${PWD:${#HOME}}"
  else
    tmp=$PWD
  fi

  # '\' and '$' must be escaped
  # ie: to enter a directory named 'aa$bb\cc' you need to escape the chars and write 'cd aa\$bb\\cc'
  # but we display a simple path in the prompt, 'aa$bb\cc', even it it is not 100% valid
  tmp=$(echo "$tmp" | sed -e 's/\\/\\\\/g' -e 's/\$/\\\\$/g')

  # max length of the path
  local lng=45
  # truncates the path if it is too long
  if [[ ${#tmp} -gt $lng ]]; then
    local offset=$((${#tmp} - $lng))
    # in user directory, keep the prefix '~/'
    if [[ ${tmp:0:2} == "~/" ]]; then
      tmp="~/...${tmp:$(($offset + 5))}"
    # otherwise, starts the truncation from the beginning
    else
      tmp="...${tmp:$(($offset + 3))}"
    fi
  fi
  echo "[${PROMPT_PATH}$tmp${COL_RES}]"
}

# exit code of previous command
__prompt_exitcode() {
  if [[ $1 != 0 ]]; then
    case $PROMPT_ERROR_BRACKET in
      '(') echo " ${PROMPT_ERROR}($1)${COL_RES}" ;;
      '[') echo " ${PROMPT_ERROR}[$1]${COL_RES}" ;;
        *) echo " ${PROMPT_ERROR}$1${COL_RES}"   ;;
    esac
  fi
}

__prompt_basic() {
  PS1="\W \$ "
}

__prompt_advanced() {
  local exit_code=$?
  PS1=""
  PS1="$PS1$(__prompt_svn)"
  PS1="$PS1$(__prompt_git)"
  PS1="$PS1$(__prompt_path)"
  PS1="$PS1$(__prompt_exitcode "$exit_code")"

  # fix an important problem with long command overlap
  # for the prompt, the reset color must be include within '\[' and '\]'
  # http://stackoverflow.com/a/706872/1503073
  if [[ $PROMPT_CHAR_COLOR == '\033[0m' ]]; then
    PS1="$PS1\n\[${COL_RES}\]${PROMPT_CHAR}\[${COL_RES}\] "
  else
    PS1="$PS1\n\[${PROMPT_CHAR_COLOR}\]${PROMPT_CHAR}\[${COL_RES}\] "
  fi
}

# set the prompt
[[ $PROMPT_TYPE == 'advanced' ]] && PROMPT_COMMAND='__prompt_advanced' || PROMPT_COMMAND='__prompt_basic'

# interactive setup
prompt() {
  # inner functions
  function get_file() {
    [[ $1 != 'color' ]] && echo ~/.dotfiles/.cache/terminal/terminal.sh && return

    if [[ $TERM_COLORS -eq 256 ]]; then
      [[ $TERM_BACKGROUND_BRIGHTNESS -gt 128 ]]       \
        && echo ~/.dotfiles/.cache/terminal/terminal-bright-256.sh \
        || echo ~/.dotfiles/.cache/terminal/terminal-dark-256.sh

    else
      [[ $TERM_BACKGROUND_BRIGHTNESS -gt 128 ]]   \
        && echo ~/.dotfiles/.cache/terminal/terminal-bright.sh \
        || echo ~/.dotfiles/.cache/terminal/terminal-dark.sh
    fi
  }
  function modif_file() {
    local file=`get_file`
    [[ $1 == 'color' ]] && file=`get_file color`
    [[ -z $2 ]] && return
    local tmp=`mktemp /tmp/prompt.XXXXX`
    sed "$2" $file > $tmp && mv $tmp $file
    rm -f $tmp
    source $file
  }
  function line() {
    local s='['
    [[ $1 -eq 1 ]] && s="${s}git "
    s="${s}${2}master${COL_RES}:"
    s="${s}${3}sta${COL_RES}-"
    s="${s}${4}mod${COL_RES}-"
    s="${s}${5}unt${COL_RES}]["
    s="${s}${6}path/to/directory${COL_RES}] "
    [[ $7 -ne 1 ]] && echo $s && return
    s="${s}${8}"
    if [[ $9 == '[' ]]; then
      s="${s}[127]${COL_RES}"
    elif [[ $9 == '(' ]]; then
      s="${s}(127)${COL_RES}"
    elif [[ $9 -eq 0 ]]; then
      s="${s}127${COL_RES}"
    fi
    echo $s
  }
  function choose() {
    # $1 : type of modification, ie: vcs
    # $2 : the index of current selected choice
    local idx=0
    if [[ $1 != 'char' || $1 != 'char_color' ]]; then
      local args=($PROMPT_VCS $PROMPT_BRANCH $PROMPT_STAGED $PROMPT_MODIFIED $PROMPT_UNTRACKED $PROMPT_PATH)
      if [[ $1 == 'error' || $1 == 'error_bracket' ]]; then
        args+=(1 $PROMPT_ERROR $PROMPT_ERROR_BRACKET)
      fi
      local i=
      case $1 in
              vcs) i=0 ;;
           branch) i=1 ;;
           staged) i=2 ;;
         modified) i=3 ;;
        untracked) i=4 ;;
             path) i=5 ;;
            error) i=7 ;;
    error_bracket) i=8 ;;
      esac
    fi

    clear
    echo
    for e in ${choices[@]}; do
      [[ $idx == $2 ]] && echo -en "$PUCE" || echo -en "    "

      if [[ $1 == 'char' ]]; then
        echo -e "$e"
      elif [[ $1 == 'char_color' ]]; then
        echo -e "${e}${PROMPT_CHAR}${COL_RES}"
      else
        args[$i]=$e
        echo -e `line ${args[@]}`
      fi
      idx=$((idx+1))
    done
    echo
  }
  function setup() {
    # $1 : the current variable value, ie: "$PROMPT_UNTRACKED"
    # $2 : the name of the choose argument function, ie: untracked
    # $3 : to target the config file, must be '' or color
    # $4 : the sed pattern, ie: PROMPT_UNTRACKED
    # variable 'choices' must be define outside
    local cnt=$((${#choices[@]} - 1))
    local idx=0

    for e in ${choices[@]}; do
      [[ "$e" == "$1" ]] && break;
      idx=$((idx + 1))
    done
    local prv=$idx
    eval "choose $2 $idx"

    while true; do
    read -s -n 3 c
    case "$c" in
      $UP)
        [[ $idx -gt 0 ]] && idx=$((idx - 1))
        eval "choose $2 $idx"
        ;;
      $DOWN)
        [[ $idx -lt $cnt ]] && idx=$((idx + 1))
        eval "choose $2 $idx"
        ;;
      *)
        clear
        [[ $prv -eq $idx ]] && break

        if [[ "$3" == 'color' ]]; then
          modif_file "$3" "/$4=/ s/.*/$4='\\${choices[$idx]}'/"
        else
          modif_file "$3" "/$4=/ s/.*/$4='${choices[$idx]}'/"
        fi
        break
        ;;
      esac
    done
  }
  function configure() {
    local UP=$'\033[A'
    local DOWN=$'\033[B'
    local PUCE="  \033[0;35mx\033[0m "

    # vcs
    local choices=("${PROMPT_VCS_CHOICES[@]}")
    setup "$PROMPT_VCS" vcs '' PROMPT_VCS

    # branch
    choices=("${PROMPT_BRANCH_CHOICES[@]}")
    setup "$PROMPT_BRANCH" branch color PROMPT_BRANCH

    if [[ $TERM_COLORS -eq 256 ]]; then
      # staged
      choices=("${PROMPT_STAGED_CHOICES[@]}")
      setup "$PROMPT_STAGED" staged color PROMPT_STAGED

      # modified
      choices=("${PROMPT_MODIFIED_CHOICES[@]}")
      setup "$PROMPT_MODIFIED" modified color PROMPT_MODIFIED
    fi

    # untracked
    choices=("${PROMPT_UNTRACKED_CHOICES[@]}")
    setup "$PROMPT_UNTRACKED" untracked color PROMPT_UNTRACKED

    # path
    choices=("${PROMPT_PATH_CHOICES[@]}")
    setup "$PROMPT_PATH" path color PROMPT_PATH

    if [[ $TERM_COLORS -eq 256 ]]; then
      # error
      choices=("${PROMPT_ERROR_CHOICES[@]}")
      setup "$PROMPT_ERROR" error color PROMPT_ERROR
    fi

    # error bracket
    choices=("${PROMPT_ERROR_BRACKET_CHOICES[@]}")
    setup "$PROMPT_ERROR_BRACKET" error_bracket '' PROMPT_ERROR_BRACKET

    # prompt char
    choices=("${PROMPT_CHAR_CHOICES[@]}")
    setup "$PROMPT_CHAR" char '' PROMPT_CHAR

    # prompt char color
    choices=("${PROMPT_CHAR_COLOR_CHOICES[@]}")
    setup "$PROMPT_CHAR_COLOR" char_color color PROMPT_CHAR_COLOR
  }
  function switch() {
    local new=basic
    [[ $PROMPT_TYPE == 'basic' ]] && new=advanced
    modif_file '' "/PROMPT_TYPE=/ s/.*/PROMPT_TYPE='$new'/"
    source ~/.dotfiles/osx/source/prompt.sh
  }

  echo
  echo "  c) configure the prompt"
  local new=basic
  [[ $PROMPT_TYPE == 'basic' ]] && new=advanced
  echo "  s) switch to $new prompt"
  echo "  a) abort"
  echo
  while true; do
    echo -n "select an action [aCs] : "
    read r
    r=$(echo "$r" | tr '[A-Z]' '[a-z]')
    case "$r" in
         a) break;;
      c|'') configure; break;;
         s) switch; break;;
    esac
  done

  unset -f get_file
  unset -f modif_file
  unset -f line
  unset -f choose
  unset -f setup
  unset -f configure
  unset -f switch
}
