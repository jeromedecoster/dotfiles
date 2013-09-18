alias ..="cd .."
alias ...="cd ../.."

# subl is a symbolic link created during the ~/.dotfiles installation
alias s="subl"
# browse is my .dotfiles/osx/bin/browse executable
alias b="browse"
# manh is my .dotfiles/osx/bin/manh executable
alias mh="manh"

# git aliases...
alias ga="git add"
# add all files (also when not in the repository root)
alias gaa="git rev-parse --show-toplevel | xargs git add"
alias gb="git branch"
# delete a branch
alias gbd="git branch -D"
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gcg="git config --global --list"
# switch on a branch
alias gco="git checkout"
# create a branch and switch on it
alias gcob="git checkout -b"
alias gl="git log --pretty='format:%Cgreen%h%Creset %an - %s' --graph"
# update master branch on remote (push to github)
alias gpom="git push -u origin master"
# back to the last commit (undo local modifications)
alias grh="git reset --hard"
alias gs="git status"
# git extensions
alias gig="git ignore"
alias gsu="git summary"
alias gun="git undo"
