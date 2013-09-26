require 'spec_helper'
require 'crap_helper'

# detection inside a git directory
describe 'crap executable' do

  let(:git) { "#{SUPPORT}/crap/git" }

  before do
    `rm -fr #{SUPPORT}/crap`
    `mkdir -p "#{git}"`
    # copy git-crap (includes some crap files already tracked)
    `cp -r "#{SUPPORT}/assets/git-crap/" "#{git}"`
    # create new crap files, add them but do not stage/commit them
    Dir.chdir "#{git}"
    `echo "data" > "#{git}/Thumbs.db"`
    `git add "#{git}/Thumbs.db"`
    `touch "#{git}/.zero"`
    `git add "#{git}/.zero"`
  end
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'should not list registered zero ko files' do
    # skip

    arr = Open3.capture2("crap -z")[0].split "\n"
    # not registered files
    arr.include?('path/.zero').must_equal true
    arr.include?('path/zero').must_equal true
    # registered files
    arr.include?('.zero').must_equal false
    arr.include?('path/to/.zero').must_equal false
    arr.include?('path/to/directory/zero').must_equal false
  end

  it 'should not list registered crap files' do
    # skip

    arr = Open3.capture2("crap -c")[0].split "\n"
    # not registered directories
    arr.include?('path/.Spotlight-V100').must_equal true
    arr.include?('path/.TemporaryItems').must_equal true
    arr.include?('path/to/.fseventsd').must_equal true
    arr.include?('path/to/directory/Thumbs.db').must_equal true
    arr.include?('path/to/directory/.DS_Store').must_equal true
    # registered directories
    arr.include?('Thumbs.db').must_equal false
    arr.include?('path/to/Thumbs.db').must_equal false
    arr.include?('path/to/directory/desktop.ini').must_equal false
  end
end
