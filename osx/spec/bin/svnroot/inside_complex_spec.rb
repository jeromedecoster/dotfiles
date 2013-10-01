
# inside a mix of svn directories
describe 'svnroot executable' do

  let(:crap)   { "#{SUPPORT}/svnroot/svn-crap" }
  let(:simple) { "#{SUPPORT}/svnroot/svn-crap/path/to/svn-simple" }

  before do
    `rm -fr #{SUPPORT}/svnroot`
    `mkdir -p "#{crap}"`
    # copy svn-crap
    `cp -r "#{SUPPORT}/assets/svn-crap/" "#{crap}"`
    # copy svn-simple
    `cp -r "#{SUPPORT}/assets/svn-simple/" "#{simple}"`
    `touch "#{simple}/path/to/file"`
    Dir.chdir "#{simple}/path/to"
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
end
