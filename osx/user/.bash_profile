# add ~/.dotfiles/osx/bin into the PATH
PATH=~/.dotfiles/osx/bin:$PATH
export PATH

# source some files in ~/.dotfiles/source/
for file in ~/.dotfiles/osx/source/{prompt,aliases,functions,libs,completion}.sh; do
    # if the file is readable by the user, source it
    [ -r "$file" ] && source "$file"
done

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
