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
for file in ~/.dotfiles/osx/source/{prompt,aliases,functions,libs,completion}.sh; do
  # if the file is readable by the user, source it
  [[ -r "$file" ]] && source "$file"
done
unset file

# rbenv executable found but _rbenv is not yet a function
if [[ `type -P rbenv` && -z `type -t _rbenv` ]]; then
  # init rbenv
  eval "`rbenv init -`"
fi

# dirty hack to disable homebrew warning 'It appears you have MacPorts or Fink installed'
# when you install or upgrade a formula
brew() {
  if [[ `type -P brew` ]]; then
    local path=`type -P brew`

    # if 'brew install' or 'brew upgrade' are invoked
    if [[ $1 == 'install' || $1 == 'upgrade' ]]; then
      local cwd="$(pwd)"
      local prefix=`eval "$path --prefix"`
      local file=`echo $prefix/Library/Homebrew/cmd/install.rb`

      # if uncommented line found in Homebrew/cmd/install.rb to check macports, comment it
      if [[ -f $file && `egrep '^[[:blank:]]+check_macports$' $file` ]]; then
        local tmp=`mktemp /tmp/homebrew.XXXXX`
        sed -E '/^[[:blank:]]+check_macports$/ s/^/#/' $file > $tmp && mv $tmp $file
        rm -f $tmp

        # execute brew
        eval "$path $@"

        # then revert the commented file
        cd "$prefix"
        git checkout $file
        cd "$cwd"
      # fallback, but normally you should never go here
      else
        eval "$path $@"
      fi
    # other commands
    else
      eval "$path $@"
    fi
  else
    `echo 'brew: command not found' >&2; exit 127`
  fi
}
