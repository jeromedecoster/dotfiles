# source some files in ~/.dotfiles/source/
for file in ~/.dotfiles/source/.{extra,prompt,aliases,functions}; do
    # if the file is readable by the user, source it
    [ -r "$file" ] && source "$file"
done