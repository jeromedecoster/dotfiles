# display svn infos when inside a repository directory
function prompt_svn() {
    local info="$(svn info . 2> /dev/null)"
    if [[ "$info" ]]; then
        local files rev
        files=$(find . -depth 1 ! -name ".svn" ! -name ".DS_Store")
        # if no file in this svn directory, return a basic prompt info
        # with the last change revision of the current directory
        if [[ ! "$files" ]]; then
            rev=$(echo "$info" | awk '/^Last Changed Rev:/ { print $4 }')
            echo "[svn r$rev]" && return
        fi

        local status mod mis unt min max
        # check for modified, missing or untracked files
        status=$(svn status)
        mod=$(echo "$status" | awk '/^[ADM]/ { print 1 }')
        mis=$(echo "$status" | awk '/^\!/ { print 1 }')
        unt=$(echo "$status" | awk '/^\?/ { print 1 }')
        # echo "mod:$mod"
        # echo "mis:$mis"
        # echo "unt:$unt"
        for f in $files; do
            info=$(svn info $f 2> /dev/null)
            # if info, means this file is managed by svn
            if [[ "$info" ]]; then
                rev=$(echo "$info" | awk '/^Last Changed Rev:/ { print $4 }')
                if [[ "$min" ]]; then
                    [[ $rev -gt $max ]] && max=$rev
                    [[ $rev -lt $min ]] && min=$rev
                else
                    # init vars
                    min=$rev && max=$rev
                fi
            fi
        done
        unset f

        if [[ ! "$mod" && ! "$mis" && ! "$unt" ]]; then
            [[ $min -lt $max ]] && echo "[svn r$min-r$max]" || echo "[svn r$max]"
        else
            local RED="\033[0;31m"
            local BLU="\033[0;34m"
            local YEL="\033[0;33m"
            local RES="\033[0m"
            local warn=""
            [[ "$mod" ]] && warn="${warn}-${RED}mod${RES}"
            [[ "$mis" ]] && warn="${warn}-${BLU}mis${RES}"
            [[ "$unt" ]] && warn="${warn}-${YEL}unt${RES}"
            # if warn starts with a dash, remove it
            [[ ${warn:0:1} == "-" ]] && warn=${warn:1}
            echo "[svn r$min-r$max:$warn]"
        fi
    fi
}

# display git infos when inside a repository directory
function prompt_git() {
    local status output flags
    status="$(git status 2>/dev/null)"
    # if pwd is inside a Git repo, the exit code ($?) will be != than 0
    [[ $? != 0 ]] && return;
    # if initial commit, output = '(init)'
    output="$(echo "$status" | awk '/# Initial commit/ {print "(init)"}')"
    # if output is empty, output = <branch-name>
    [[ "$output" ]] || output="$(echo "$status" | awk '/# On branch/ {print $4}')"
    
    flags="$(
            echo "$status" | awk 'BEGIN {r=0} \
            /^# Changes to be committed:$/        {r+=4}\
            /^# Changes not staged for commit:$/  {r+=2}\
            /^# Untracked files:$/                {r+=1}\
            END {print r}'
        )"
    # 'ready to commit' add 4 to flags, 4 means [1 0 0]
    # so if flags == 4 or 6 [1 1 0] or 7 [1 1 1],
    # means there is files 'ready to commit'
    # 
    # 'not staged' add 2 to flags, 2 means [0 1 0]
    # so if flags == 2 or 6 [1 1 0] or 7 [1 1 1],
    # means there is modified files 'waiting to be staged'
    # 
    # 'untracked files' add 1 to flags, 1 means [0 0 1]
    # so if flags == 1 or 5 [1 0 1] or 7 [1 1 1],
    # means there is 'untracked files'

    local com mod unt warn
    # shit 2 times to the right and check if == 1
    # from [1 0 0] to [- - 1]
    com=$((((flags>>2))==1))
    # shit 1 time to the right and check with bitwise mask AND (&)
    # if first position == 1
    # from [0 1 0] to [- 0 1]
    mod=$((((flags>>1&1))==1))
    # check with bitwise mask AND (&) if first position == 1
    unt=$((((flags&1))==1))

    local RED="\033[0;31m"
    local GRE="\033[0;32m"
    local YEL="\033[0;33m"
    local RES="\033[0m"
    warn=""
    [[ $com -eq 1 ]] && warn="${GRE}com${RES}"
    [[ $mod -eq 1 ]] && warn="${warn}-${RED}mod${RES}"
    [[ $unt -eq 1 ]] && warn="${warn}-${YEL}unt${RES}"
    # if warn starts with a dash, remove it
    [[ ${warn:0:1} == "-" ]] && warn=${warn:1}
    if [[ "$warn" ]]; then
        echo "[git $output:$warn]"
    else
        echo "[git $output]"
    fi
}

# the current directory path displayed in the advanced prompt
function prompt_path() {
    local tmp lng
    if [[ $PWD == $HOME ]]; then
        echo "[~]" && return
    elif [[ $HOME ==  ${PWD:0:${#HOME}} ]]; then
        tmp="~${PWD:${#HOME}}"
    else
        tmp=$PWD
    fi
    # max length of the path
    lng=45
    if [[ ${#tmp} -gt $lng ]]; then
        local offset=$((${#tmp} - $lng))
        local GRY="\033[0;37m"
        local RES="\033[0m"
        if [[ ${tmp:0:2} == "~/" ]]; then
            # in user directory, keep the prefix '~/' ...
            tmp="~/${GRY}...${RES}${tmp:$(($offset + 5))}"
        else
            # ...or starts the truncation from the beginning
            tmp="${GRY}...${RES}${tmp:$(($offset + 3))}"
        fi
    fi
    echo "[$tmp]"
}

# exit code of previous command
function prompt_exitcode() {
    local RED="\033[0;31m"
    local RES="\033[0m"
    [[ $1 != 0 ]] && echo " $RED($1)$RES"
}

function prompt_basic() {
    PS1="\W \$ "
}

function prompt_advanced() {
    local exit_code=$?
    PS1=""
    PS1="$PS1$(prompt_svn)"
    PS1="$PS1$(prompt_git)"
    PS1="$PS1$(prompt_path)"
    PS1="$PS1$(prompt_exitcode "$exit_code")"
    PS1="$PS1\n\$ "
}

# set the default prompt as advanced
PROMPT_COMMAND="prompt_advanced"