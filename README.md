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

Ruby must be <a href="http://rubyinstaller.org" target="_blank">installed</a>

Open the Powershell console and execute in 3 steps, line by line, the command

```powershell
$f="$env:temp\install"; $wc=New-Object System.Net.WebClient
$wc.DownloadFile("https://raw.github.com/jeromedecoster/dotfiles/master/bin/install",$f)
ruby $f
```
