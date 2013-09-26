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