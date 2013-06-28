# add ~/.dotfiles/bin into the PATH
PATH=~/.dotfiles/win/bin:$PATH
export PATH

# source some files in ~/.dotfiles/source/
for file in ~/.dotfiles/win/source/{prompt,aliases,functions,libs,completion}.sh; do
    # if the file is readable by the user, source it
    [ -r "$file" ] && source "$file"
done