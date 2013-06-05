Dotfiles
========

My OS X / Windows dotfiles FTW!

## Installation
### OS X

Open the Terminal and execute the command

```bash
bash -c "$(curl -fsSL raw.github.com/jeromedecoster/dotfiles/master/osx/install)" && source ~/.bash_profile
```

### Windows

Ruby must be <a target="_new" href="http://rubyinstaller.org">installed</a>

Open the Powershell console and execute in 3 steps, line by line, the command

```powershell
$f="$env:temp\install"; $wc=New-Object System.Net.WebClient
$wc.DownloadFile("https://raw.github.com/jeromedecoster/dotfiles/master/bin/install",$f)
ruby $f
```
