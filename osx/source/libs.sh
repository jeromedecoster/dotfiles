# z

# override the default z cache location ~/.z
_Z_DATA=~/.dotfiles/.cache/.z

# disable the default z prompt behavior
# this behavior add an invisible function call to the prompt to update/save
# the z cache file each time the terminal is opened or a directory is 'cd'
# it means all the locations you browse with the terminal is stored
# I prefer manually add or remove some specific directories
_Z_NO_PROMPT_COMMAND=1

# source z, it's not a command, it's just a function called from a
# bash or zsh completion command
source ~/.dotfiles/osx/lib/z/z.sh

# add the current folder to the z cache or increase his rank if already here
function za() {
    z --add "$PWD"
}

# remove the pwd from the z cache
# the folders that no longer exist will be also deleted
function zr() {
    local data="${_Z_DATA:-$HOME/.z}"
    if [[ -f "$data" ]]; then
        local old_IFS lines folder cur result
        old_IFS=$IFS
        IFS=$'\n'
        lines=($(cat "$data"))
        IFS=$old_IFS
        cur="$(pwd)"
        result=()
        for i in "${lines[@]}"; do
            # extract the directory path from the cache line (the safest way posible)
            folder=$(echo "$i" | awk -F '|' '
            {   
                if (NF == 3) {
                    print $1
                }
                else {
                    s = ""
                    for ( i=1; i<(NF-1); i++)
                    {
                        s = s "|" $i
                    }
                    print substr(s,2)
                }
            }')
            # if it's not the pwd and if it's a directory, push
            # the cache line to the result array
            if [[ "$folder" != "$cur" && -d "$folder" ]]; then
                result+=("$i")
            fi
        done
        unset i
        # if the count of lines array and result array are different, means
        # something was deleted
        if [[ ${#lines[@]} -ne ${#result[@]} ]]; then
            # join the result array with the newline char and
            # override the z cache file with it
            old_IFS=$IFS
            IFS=$'\n'
            echo -e "${result[*]}" > "$data"
            IFS=$old_IFS
        fi
    fi
}
