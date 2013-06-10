Dotfiles
========

My OS X / Windows dotfiles

Mainly inspired by Ben Alman's <a href="https://github.com/cowboy/dotfiles" target="_blank">dotfiles</a> but everything was rewritten from scratch

## Installation
### OS X

Open the Terminal and execute

```bash
bash -c "$(curl -fsSL raw.github.com/jeromedecoster/dotfiles/master/osx/install)" && source ~/.bash_profile
```

### Windows

Open the classic or Powershell console and execute

```powershell
powershell -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/jeromedecoster/dotfiles/master/win/install.ps1'))"
```
