# define global variable, value must be 8 in Terminal or 256 in iTerm
TERM_COLORS=`tput colors`
export TERM_COLORS

terminal_brightness() {
  local cmd
  arch -i386 pwd &>/dev/null
  [[ $? -eq 0 ]] && cmd="arch -i386 osascript" || cmd="osascript"
  if [[ $TERM_PROGRAM == 'iTerm.app' ]]; then
    eval "$cmd" <<EOF
  tell application "iTerm"
    tell the current terminal
      tell the current session
        set col to background color
        set r to (item 1 of col) / 257
        set g to (item 2 of col) / 257
        set b to (item 3 of col) / 257
        round (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
      end tell
    end tell
  end tell
EOF
  # if it's not iTerm, it must be the classic Terminal, no other alternative
  else
    eval "$cmd" <<EOF
  tell application "Terminal"
    set col to background color of first window
    set r to (item 1 of col) / 257
    set g to (item 2 of col) / 257
    set b to (item 3 of col) / 257
    round (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
  end tell
EOF
  fi
}

# define global variable, value must be between 0 and 255
TERM_BACKGROUND_BRIGHTNESS=`terminal_brightness`
export TERM_BACKGROUND_BRIGHTNESS
unset -f terminal_brightness

# define global color variables, only used variables are declared
if [[ $TERM_COLORS -eq 256 ]]; then
  # COL_BLA='\033[38;5;0m'
  COL_RED='\033[38;5;196m'     ; export COL_RED
  # COL_GRE='\033[38;5;46m'
  # COL_YEL='\033[38;5;226m'
  COL_BLU='\033[38;5;21m'      ; export COL_BLU
  COL_YEL='\033[38;5;226m'     ; export COL_YEL
  COL_PIN='\033[38;5;201m'     ; export COL_PIN
  COL_CYA='\033[38;5;51m'      ; export COL_CYA
  COL_WHI='\033[38;5;231m'     ; export COL_WHI
  # COL_BLA_RED1='\033[38;5;52m'
  COL_BLA_RED2='\033[38;5;88m' ; export COL_BLA_RED2
  COL_BLA_RED3='\033[38;5;124m'; export COL_BLA_RED3
  COL_BLA_RED4='\033[38;5;160m'; export COL_BLA_RED4
  # COL_BLA_GRE1='\033[38;5;22m'
  COL_BLA_GRE2='\033[38;5;28m' ; export COL_BLA_GRE2
  COL_BLA_GRE3='\033[38;5;34m' ; export COL_BLA_GRE3
  COL_BLA_GRE4='\033[38;5;40m' ; export COL_BLA_GRE4
  COL_BLA_YEL1='\033[38;5;58m' ; export COL_BLA_YEL1
  COL_BLA_YEL2='\033[38;5;100m'; export COL_BLA_YEL2
  COL_BLA_YEL3='\033[38;5;142m'; export COL_BLA_YEL3
  COL_BLA_YEL4='\033[38;5;184m'; export COL_BLA_YEL4
  COL_BLA_BLU1='\033[38;5;17m' ; export COL_BLA_BLU1
  COL_BLA_BLU2='\033[38;5;18m' ; export COL_BLA_BLU2
  # COL_BLA_BLU3='\033[38;5;19m'
  COL_BLA_BLU4='\033[38;5;20m' ; export COL_BLA_BLU4
  COL_BLA_PIN1='\033[38;5;53m' ; export COL_BLA_PIN1
  COL_BLA_PIN2='\033[38;5;90m' ; export COL_BLA_PIN2
  COL_BLA_PIN3='\033[38;5;127m'; export COL_BLA_PIN3
  COL_BLA_PIN4='\033[38;5;164m'; export COL_BLA_PIN4
  COL_BLA_CYA1='\033[38;5;27m' ; export COL_BLA_CYA1
  COL_BLA_CYA2='\033[38;5;33m' ; export COL_BLA_CYA2
  COL_BLA_CYA3='\033[38;5;39m' ; export COL_BLA_CYA3
  COL_BLA_CYA4='\033[38;5;45m' ; export COL_BLA_CYA4
  COL_BLA_WHI1='\033[38;5;237m'; export COL_BLA_WHI1
  COL_BLA_WHI2='\033[38;5;241m'; export COL_BLA_WHI2
  COL_BLA_WHI3='\033[38;5;246m'; export COL_BLA_WHI3
  # COL_BLA_WHI4='\033[38;5;251m'
  # COL_RED_GRE1='\033[38;5;166m'
  # COL_RED_GRE2='\033[38;5;136m'
  # COL_RED_GRE3='\033[38;5;106m'
  # COL_RED_GRE4='\033[38;5;76m'
  # COL_RED_YEL1='\033[38;5;202m'
  # COL_RED_YEL2='\033[38;5;208m'
  # COL_RED_YEL3='\033[38;5;214m'
  # COL_RED_YEL4='\033[38;5;220m'
  # COL_RED_BLU1='\033[38;5;161m'
  # COL_RED_BLU2='\033[38;5;126m'
  # COL_RED_BLU3='\033[38;5;91m'
  # COL_RED_BLU4='\033[38;5;56m'
  # COL_RED_PIN1='\033[38;5;197m'
  # COL_RED_PIN2='\033[38;5;198m'
  # COL_RED_PIN3='\033[38;5;199m'
  # COL_RED_PIN4='\033[38;5;200m'
  # COL_RED_CYA1='\033[38;5;167m'
  # COL_RED_CYA2='\033[38;5;138m'
  # COL_RED_CYA3='\033[38;5;109m'
  # COL_RED_CYA4='\033[38;5;80m'
  # COL_RED_WHI1='\033[38;5;203m'
  # COL_RED_WHI2='\033[38;5;210m'
  # COL_RED_WHI3='\033[38;5;217m'
  # COL_RED_WHI4='\033[38;5;224m'
  # COL_GRE_YEL1='\033[38;5;82m'
  # COL_GRE_YEL2='\033[38;5;118m'
  # COL_GRE_YEL3='\033[38;5;154m'
  # COL_GRE_YEL4='\033[38;5;190m'
  # COL_GRE_CYA1='\033[38;5;47m'
  # COL_GRE_CYA2='\033[38;5;48m'
  # COL_GRE_CYA3='\033[38;5;49m'
  # COL_GRE_CYA4='\033[38;5;50m'
  # COL_GRE_WHI1='\033[38;5;83m'
  # COL_GRE_WHI2='\033[38;5;120m'
  # COL_GRE_WHI3='\033[38;5;157m'
  # COL_GRE_WHI4='\033[38;5;194m'
  # COL_YEL_CYA1='\033[38;5;191m'
  # COL_YEL_CYA2='\033[38;5;156m'
  # COL_YEL_CYA3='\033[38;5;121m'
  # COL_YEL_CYA4='\033[38;5;86m'
  # COL_YEL_WHI1='\033[38;5;227m'
  COL_YEL_WHI2='\033[38;5;228m'; export COL_YEL_WHI2
  # COL_YEL_WHI3='\033[38;5;229m'
  # COL_YEL_WHI4='\033[38;5;230m'
  # COL_BLU_GRE1='\033[38;5;26m'
  # COL_BLU_GRE2='\033[38;5;31m'
  # COL_BLU_GRE3='\033[38;5;36m'
  # COL_BLU_GRE4='\033[38;5;41m'
  # COL_BLU_YEL1='\033[38;5;62m'
  # COL_BLU_YEL2='\033[38;5;103m'
  # COL_BLU_YEL3='\033[38;5;144m'
  # COL_BLU_YEL4='\033[38;5;179m'
  # COL_BLU_PIN1='\033[38;5;57m'
  # COL_BLU_PIN2='\033[38;5;93m'
  # COL_BLU_PIN3='\033[38;5;129m'
  # COL_BLU_PIN4='\033[38;5;165m'
  # COL_BLU_CYA1='\033[38;5;27m'
  # COL_BLU_CYA2='\033[38;5;33m'
  # COL_BLU_CYA3='\033[38;5;39m'
  # COL_BLU_CYA4='\033[38;5;45m'
  # COL_BLU_WHI1='\033[38;5;63m'
  COL_BLU_WHI2='\033[38;5;105m'; export COL_BLU_WHI2
  COL_BLU_WHI3='\033[38;5;147m'; export COL_BLU_WHI3
  # COL_BLU_WHI4='\033[38;5;189m'
  # COL_PIN_YEL1='\033[38;5;206m'
  # COL_PIN_YEL2='\033[38;5;211m'
  # COL_PIN_YEL3='\033[38;5;216m'
  # COL_PIN_YEL4='\033[38;5;221m'
  # COL_PIN_CYA1='\033[38;5;171m'
  # COL_PIN_CYA2='\033[38;5;141m'
  # COL_PIN_CYA3='\033[38;5;111m'
  # COL_PIN_CYA4='\033[38;5;81m'
  COL_PIN_WHI1='\033[38;5;207m'; export COL_PIN_WHI1
  COL_PIN_WHI2='\033[38;5;213m'; export COL_PIN_WHI2
  # COL_PIN_WHI3='\033[38;5;219m'
  # COL_PIN_WHI4='\033[38;5;225m'
  # COL_CYA_WHI1='\033[38;5;87m'
  # COL_CYA_WHI2='\033[38;5;123m'
  COL_CYA_WHI3='\033[38;5;159m'; export COL_CYA_WHI3
  # COL_CYA_WHI4='\033[38;5;195m'
else
  # COL_BLA='\033[0;30m'; export COL_BLA
  COL_RED='\033[0;31m'; export COL_RED
  COL_GRE='\033[0;32m'; export COL_GRE
  COL_YEL='\033[0;33m'; export COL_YEL
  COL_BLU='\033[0;34m'; export COL_BLU
  COL_PIN='\033[0;35m'; export COL_PIN
  COL_CYA='\033[0;36m'; export COL_CYA
  COL_GRY='\033[0;37m'; export COL_GRY
fi
COL_RES='\033[0m'; export COL_RES
