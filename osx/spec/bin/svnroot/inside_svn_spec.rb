
# inside a svn directory
describe 'svnroot executable' do

  let(:svn) { "#{SUPPORT}/svnroot/svn-simple" }

  before do
    `rm -fr #{SUPPORT}/svnroot`
    `mkdir -p "#{svn}"`
    # copy svn-simple
    `cp -r "#{SUPPORT}/assets/svn-simple/" "#{svn}"`
    `touch "#{svn}/path/to/file"`
    Dir.chdir "#{svn}/path/to"
  end
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'must works' do
    # skip

    ['', '.', '..', 'directory', 'file'].each do |path|
      o, e, s = Open3.capture3 "svnroot #{path}"
      o.must_match /svn-simple$/
    end
  end

  it 'must print the usage if the target does not exist' do
    # skip

    o, e, s = Open3.capture3 "svnroot missing"
    o.must_be_empty
    e.must_match /^usage/
    s.exitstatus.must_equal 1
  end
end
