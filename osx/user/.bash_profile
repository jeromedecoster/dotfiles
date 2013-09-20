# remove $1 from the $PATH
path_remove() {
  # convert path to an array
  local tmp=$IFS
  IFS=:
  local t=($PATH)
  # remove paths found from the array
  unset IFS
  t=(${t[@]%%$1})
  # echo the result, an array joined with ':'
  IFS=:
  echo "${t[*]}"
  IFS=$tmp
}

# set /usr/local/bin before /usr/bin in the $PATH
PATH=/usr/local/bin:`path_remove /usr/local/bin`
# add ~/.dotfiles/osx/bin then /usr/local/homebrew/bin to the $PATH
PATH=/usr/local/homebrew/bin:$PATH
PATH=~/.dotfiles/osx/bin:$PATH
export PATH
unset -f path_remove

# source some files in ~/.dotfiles/source/
for file in ~/.dotfiles/osx/source/{colors,prompt,aliases,functions,libs,completion,extras}.sh; do
  # if the file is readable by the user, source it
  [[ -r "$file" ]] && source "$file"
done
unset file

# rbenv executable found but _rbenv is not yet a function
if [[ `type -P rbenv` && -z `type -t _rbenv` ]]; then
  # init rbenv
  eval "`rbenv init -`"
fi
