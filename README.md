Dotfiles
========

My OS X / Windows dotfiles are my ultimate plan to conquer the world... or at least my computer

Mainly inspired by Ben Alman's <a href="https://github.com/cowboy/dotfiles" target="_blank">dotfiles</a> but everything was rewritten from scratch

#### OS X
* [Install](#osx-install)
* [What the install script do?](#osx-what)

What is new after that?
* [What is executed when I start my Terminal?](#osx-executed)
* [The added executables](#osx-executables)
* [The added git extensions](#osx-git-extensions)
* [The added functions](#osx-functions)
* [An advanced prompt is defined](#osx-prompt)

#### Windows
* [Install](#win-install)
* [What the install script do?](#win-what)

- - -

## OS X
<a name="osx-install"/>
#### Install

Open the Terminal and execute

```bash
bash -c "$(curl -fsSL raw.github.com/jeromedecoster/dotfiles/master/osx/install)" && source ~/.bash_profile
```

<a name="osx-what"/>
#### What the install script do?

* Install <a href="http://brew.sh" target="_blank">homebrew</a> in `/usr/local/homebrew` or update your current version
* Prompt you to remove <a href="https://rvm.io" target="_blank">rvm</a>. If you don't allow it, the script is aborted
* Install or update the following homebrew formulas
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/git.rb" target="_blank">git</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/rbenv.rb" target="_blank">rbenv</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/ruby-build.rb" target="_blank">ruby-build</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/openssl.rb" target="_blank">openssl</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/phantomjs.rb" target="_blank">phantomjs</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/tree.rb" target="_blank">tree</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/man2html.rb" target="_blank">man2html</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/coreutils.rb" target="_blank">coreutils</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/wdiff.rb" target="_blank">wdiff</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/optipng.rb" target="_blank">optipng</a>
  * <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/jpeg-turbo.rb" target="_blank">jpeg-turbo</a>
* Install the latest versions of <a href="https://www.ruby-lang.org" target="_blank">Ruby</a> 1.9.3 and 2.0.0 with rbenv in `~/.rbenv/versions`
* Prompt you to install some Chrome extensions, skipped after 3 refusals
  * <a href="https://chrome.google.com/webstore/detail/empty-title/cfhdojbkjhnklbpkdaibdccddilifddb" target="_blank">Adblock Plus</a>
  * <a href="https://chrome.google.com/webstore/detail/prettyprint/nipdlgebaanapcphbcidpmmmkcecpkhg" target="_blank">PrettyPrint</a>
  * <a href="https://chrome.google.com/webstore/detail/json-formatter/bcjindcccaagfpapjjmafapmmgkkhgoa" target="_blank">JSON Formatter</a>
  * <a href="https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei" target="_blank">LiveReload</a>
* Prompt you to install some Firefox extensions, skipped after 3 refusals
  * <a href="https://addons.mozilla.org/en-US/firefox/addon/adblock-plus" target="_blank">Adblock Plus</a>
  * <a href="https://addons.mozilla.org/en-US/firefox/addon/firebug" target="_blank">Firebug</a>
  * <a href="https://getfirebug.com/releases/netexport" target="_blank">Net Export</a>
  * <a href="https://addons.mozilla.org/en-US/firefox/addon/downthemall" target="_blank">DownThemAll</a>
  * <a href="http://help.livereload.com/kb/general-use/browser-extensions" target="_blank">LiveReload</a>
* Install or update this git repository in `~/.dotfiles`
* Copy some dotfiles in your `~`. The previously existing files are backuped in `~/.dotfiles/.backup`
  * <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/user/.bash_profile" target="_blank">.bash_profile</a>
  * <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/user/.bashrc" target="_blank">.bashrc</a>
  * <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/user/.inputrc" target="_blank">.inputrc</a>
* Prompt you to configure `~/.gitconfig`

- - -

<a name="osx-executed"/>
#### What is executed when I start my Terminal?

When you start or open a new tab of your <a href="http://en.wikipedia.org/wiki/Terminal_%28OS_X%29" target="_blank">Terminal</a> or <a href="http://en.wikipedia.org/wiki/ITerm2" target="_blank">iTerm</a> console, the `~/.bash_profile` file is executed

The following steps are executed
* The `$PATH` is modified, some paths are added at start — *prepend* — in this order:
  * `~/.dotfiles/osx/bin` to allow immediate the availability of <a href="https://github.com/jeromedecoster/dotfiles/tree/master/osx/bin" target="_blank">those</a> executables
  * `/usr/local/homebrew/bin` to allow quick availability of installed formulas
  * `/usr/local/bin` which is by default placed after `/usr/bin`
* Some files are sourced from `~/.dotfiles/osx/source/` to
  * define some <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/source/colors.sh" target="_blank">colors</a>, depending on the number of colors that allows your console
  * setup an advanced <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/source/prompt.sh" target="_blank">prompt</a> explained <a href="#osx-prompt">here</a>
  * define some <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/source/aliases.sh" target="_blank">aliases</a>
  * define some <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/source/functions.sh" target="_blank">functions</a> explained <a href="#osx-functions">here</a>
  * the last sourced file, `extras.sh`, is a blank file where you can put all your personnals aliases, functions... This file is git ignored, created dynamically by the install script. So it will never modified when you will update to the dotfiles. All modifications done in other sourced files will be lost with updates
* Checks that a good Ruby version is activated with rbenv

- - -

<a name="osx-executables"/>
#### The added executables

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/browse" target="_blank">browse</a> open an uri in a browser or in the Finder

```bash
browse example.com
# or using the alias
b example.com
# open the pwd in the Finder
b
# open the parent directory in the Finder
b ..
```

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/crap" target="_blank">crap</a> allows you to remove interactively some craps files contained in a directory. Those files are:
  * OS X files: `.DS_Store` `.fseventsd` `.Spotlight-V100` `.TemporaryItems`
  * Windows files: `desktop.ini` `Thumbs.db`
  * empty directories
  * zero ko files

```bash
# list crap files from the pwd
crap
# list crap files from the parent directory
crap ..
```

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/jpeg" target="_blank">jpeg</a> allows you to compress and/or optimize jpeg files or other images format

```bash
# optimize file.jpg and save it to the directory dest
jpeg file.jpg -d dest
# compress file.jpg with the mobile setting and save it as file-mobile.jpg
jpeg -2 file.jpg -o file-mobile.jpg
```

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/lt" target="_blank">lt</a> is an advanced <a href="https://github.com/mxcl/homebrew/blob/master/Library/Formula/tree.rb" target="_blank">tree</a> listing

```bash
# list the pwd
lt
# limits the max depth to 3 directories
lt -3
```

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/manh" target="_blank">manh</a> allows you to read the <a href="http://en.wikipedia.org/wiki/Man_page" target="_blank">man pages</a> within your browser, nicely styled

```bash
manh grep
# or using the alias
mh grep
```

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/svnroot" target="_blank">svnroot</a> return the local repository root of a svn repository

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/t" target="_blank">t</a> touch multiple files at once, creates directories recursively if necessary

```bash
# touch file inside path/to
t path/to/file
# touch multiple files
t file1 file2
```

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/tx" target="_blank">tx</a> is an evolution of <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/t" target="_blank">t</a>. Chmod them as bash or ruby executables

```bash
# creates a bash executable
tx file1
# creates a ruby executable
tx -r file2
```

- - -

<a name="osx-git-extensions"/>
#### The added git extensions

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/git-ignore" target="_blank">git-ignore</a> allows you to create, list or append a local `.gitignore` file

```bash
# create .gitignore file or displays his content
git ignore
# or using the alias
gig
# add some patterns
gig *.bak temp/
```

* <a href="https://github.com/jeromedecoster/dotfiles/blob/master/osx/bin/git-summary" target="_blank">git-summary</a> displays summary informations from a git repository

```bash
git summary
# or using the alias
gsum
# displays summary for the top 3 commiters
gsum 3
```

- - -

<a name="osx-functions"/>
#### The added functions

TODO

- - -

<a name="osx-prompt"/>
#### An advanced prompt is defined

* The prompt display a colored path of the `pwd` above your command prompt
  * If too long, this path is automatically truncated with `...`
  * Within your home directory, this path is truncated with `~`
* The prompt display additional colored informations if you are in a `git` directory
  * The current branch name
  * If some files are currently staged, a green `sta` is displayed
  * If some files are currently modified, a red `mod` is displayed
  * If some files are currently untracked, a yellow `unt` is displayed
* The prompt display additional colored informations if you are in a `svn` directory
  * Display the min and max revision within the `pwd`
  * If some files are currently modified, a red `mod` is displayed
  * If some files are currently missing, a red `mis` is displayed
  * If some files are currently untracked, a yellow `unt` is displayed
* If the exit code of the last executed command is not 0, the value is displayed in red just after the path
* The colors of the prompt are automatically defined according your terminal console
  * It uses 8 or 256 colors if you use `Terminal` or `iTerm`
  * Colors are adjusted if the background of your console is dark or bright
* The colors and style of your prompt are configurable interactively with the command `prompt`

- - -

## Windows
<a name="win-install"/>
#### Install

Open the classic or Powershell console and execute

```bash
powershell -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/jeromedecoster/dotfiles/master/win/install.ps1'))"
```

<a name="win-what"/>
#### What the install script do?

The install script is currently in alpha and does nothing interesting
