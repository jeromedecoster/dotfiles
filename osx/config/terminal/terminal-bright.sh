PROMPT_BRANCH='\033[0;35m'
PROMPT_STAGED='\033[0;32m'
PROMPT_MODIFIED='\033[0;31m'
PROMPT_UNTRACKED='\033[0;33m'
PROMPT_PATH='\033[0;34m'
PROMPT_ERROR='\033[0;31m'
PROMPT_CHAR_COLOR='\033[0m'

PROMPT_BRANCH_CHOICES=($COL_RES $COL_BLU $COL_PIN $COL_CYA)
PROMPT_UNTRACKED_CHOICES=($COL_YEL $COL_CYA)
PROMPT_PATH_CHOICES=($COL_RES $COL_BLU)
PROMPT_CHAR_COLOR_CHOICES=($COL_RES $COL_BLU)

STDOUT_HIGHLIGHT=$COL_BLU        ; export STDOUT_HIGHLIGHT
STDOUT_OK=$COL_GRE               ; export STDOUT_OK
STDOUT_NOTOK=$COL_RED            ; export STDOUT_NOTOK
STDOUT_WARNING=$COL_PIN          ; export STDOUT_WARNING
STDOUT_DIRECTORY=$COL_BLU        ; export STDOUT_DIRECTORY
STDOUT_LINK=$COL_PIN             ; export STDOUT_LINK
STDOUT_BINARY_EXECUTABLE=$COL_RED; export STDOUT_BINARY_EXECUTABLE
STDOUT_TEXT_EXECUTABLE=$COL_GRE  ; export STDOUT_TEXT_EXECUTABLE
STDOUT_EMPTY_OR_MISSING=$COL_YEL ; export STDOUT_EMPTY_OR_MISSING
