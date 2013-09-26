require 'spec_helper'
require 'crap_helper'

# detection inside a svn checkout directory
describe 'crap executable' do

  let(:svn) { "#{SUPPORT}/crap/svn" }

  before do
    `rm -fr #{SUPPORT}/crap`
    `mkdir -p "#{svn}"`
    # copy checkout svn-crap (includes some crap files from the server)
    `cp -r  "#{SUPPORT}/assets/svn-crap/" "#{svn}"`
    # create new crap files, add them but do not commit them
    Dir.chdir "#{svn}"
    `mkdir -p "#{svn}/empty"`
    `svn add "#{svn}/empty"`
    `echo "data" > "#{svn}/Thumbs.db"`
    `svn add "#{svn}/Thumbs.db"`
    `touch "#{svn}/.zero"`
    `svn add "#{svn}/.zero"`
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

  it 'should not list registered empty directories' do
    # skip

    arr = Open3.capture2("crap -d")[0].split "\n"
    # not registered directories
    arr.include?('path/to/.empty').must_equal true
    arr.include?('path/to/directory/empty').must_equal true
    # registered directories
    arr.include?('empty').must_equal false
    arr.include?('path/to/empty').must_equal false
    arr.include?('path/to/directory/.empty').must_equal false
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
