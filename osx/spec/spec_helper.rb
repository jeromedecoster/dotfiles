require 'pathname'

SUPPORT = Pathname.new('~/.dotfiles-support').expand_path

# loads some require needed to execute tests
def setup
  # builds the support directory if missing
  support unless File.exist? "#{SUPPORT}/assets"

  require 'minitest/autorun'
  require 'minitest/pride'
  require 'open3'
end

# builds the SUPPORT directory
def support
  cwd = Dir.pwd

  `rm -fr #{SUPPORT}`
  # init the git-simple repository
  `mkdir -p #{SUPPORT}/assets/git-simple/path/to/directory`
  `git init #{SUPPORT}/assets/git-simple`
  # init the git-crap repository
  `mkdir -p #{SUPPORT}/assets/git-crap/path/to/directory`
  `git init #{SUPPORT}/assets/git-crap`
  add_crap "#{SUPPORT}/assets/git-crap"
  Dir.chdir "#{SUPPORT}/assets/git-crap"
  # note: it's impossible to add an empty directory to a git repository
  `git add path/to/directory/desktop.ini`
  `git add path/to/directory/zero`
  `git add path/to/Thumbs.db`
  `git add path/to/.zero`
  `git commit -m "add some crap files"`

  # init the svn repository
  `svnadmin create #{SUPPORT}/assets/svn-repository`
  uri = "file://#{File.expand_path SUPPORT}/assets/svn-repository"
  # init the svn-simple repository
  `svn mkdir -q -m "mkdir svn-simple" "#{uri}/svn-simple"`
  `svn mkdir -q -m "mkdir trunk" "#{uri}/svn-simple/trunk"`
  `svn mkdir -q -m "mkdir tags" "#{uri}/svn-simple/tags"`
  `svn mkdir -q -m "mkdir branches" "#{uri}/svn-simple/branches"`
  # init the svn-simple checkout
  `mkdir -p "#{SUPPORT}/assets/svn-simple"`
  Dir.chdir "#{SUPPORT}/assets/svn-simple"
  `svn -q checkout "#{uri}/svn-simple/trunk" .`
  `mkdir -p path/to/directory`
  `svn add path`
  `svn commit -m "add path/to/directory"`
  # init the svn-crap repository
  `svn mkdir -q -m "mkdir svn-crap" "#{uri}/svn-crap"`
  `svn mkdir -q -m "mkdir trunk" "#{uri}/svn-crap/trunk"`
  `svn mkdir -q -m "mkdir tags" "#{uri}/svn-crap/tags"`
  `svn mkdir -q -m "mkdir branches" "#{uri}/svn-crap/branches"`
  # init the svn-crap checkout
  `mkdir -p "#{SUPPORT}/assets/svn-crap"`
  Dir.chdir "#{SUPPORT}/assets/svn-crap"
  `svn -q checkout "#{uri}/svn-crap/trunk" .`
  `mkdir -p path/to/directory`
  `svn add path`
  `svn commit -m "add path/to/directory"`
  add_crap "#{SUPPORT}/assets/svn-crap"
  `svn add path/to/directory/.empty`
  `svn add path/to/directory/desktop.ini`
  `svn add path/to/directory/zero`
  `svn add path/to/empty`
  `svn add path/to/Thumbs.db`
  `svn add path/to/.zero`
  `svn commit -m "add some crap files"`

  Dir.chdir cwd
end

# creates craps files
def add_crap path
  cwd = Dir.pwd
  `mkdir -p #{path}/path/to/directory`
  Dir.chdir "#{path}/path/to/directory"
  3.times do
    # crap files
    `echo "data" > .DS_Store`
    `echo "data" > desktop.ini`
    `echo "data" > Thumbs.db`
    `mkdir .fseventsd`
    `echo "data" > .fseventsd/data`
    `mkdir .Spotlight-V100`
    `echo "data" > .Spotlight-V100/data`
    `mkdir .TemporaryItems`
    `echo "data" > .TemporaryItems/data`
    # zero ko files
    `touch .zero`
    `touch zero`
    # empty dir
    `mkdir -p .empty`
    `mkdir -p empty`
    Dir.chdir '..'
  end
  Dir.chdir cwd
end
