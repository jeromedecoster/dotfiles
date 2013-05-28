function _rakecomplete() {
    # if there is only one previous word (so it will be rake)
    if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
        local t=$(rake --tasks 2>/dev/null)
        # no Rakefile found
        if [[ ! "$t" ]]; then
            COMPREPLY=($(compgen -W "no-rakefile"))
        else
            # count the lines, excluding the header that locate
            # the Rakefile (in path/to/rakefile)
            local c=$(echo "$t" | grep -E '^[^(]' -c)
            # no line, means no task
            if [[ $c -eq 0 ]]; then
                COMPREPLY=($(compgen -W "no-task"))
            else
                # task names to words
                local w=$(echo "$t" | tail -n +2 | awk '{print $2}')
                COMPREPLY=($(compgen -W "$w"))
            fi
        fi
    fi
}

complete -o default -o nospace -F _rakecomplete rake