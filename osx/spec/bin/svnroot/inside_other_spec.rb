
# inside a non svn directory
describe 'svnroot executable' do

  let(:git) { "#{SUPPORT}/svnroot/git-simple" }

  before do
    `rm -fr #{SUPPORT}/svnroot`
    `mkdir -p "#{git}"`
    # copy git-simple
    `cp -r "#{SUPPORT}/assets/git-simple/" "#{git}"`
    Dir.chdir "#{git}/path/to"
  end
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'with . or without path' do
    # skip

    ['', '.'].each do |path|
      o, e, s = Open3.capture3 "svnroot #{path}"
      o.must_be_empty
      e.must_match /'\.' is not a working copy/
      s.exitstatus.must_equal 1
    end
  end

  it 'with a path' do
    # skip

    ['..', '../'].each do |path|
      o, e, s = Open3.capture3 "svnroot #{path}"
      o.must_be_empty
      e.must_match /'\.\.' is not a working copy/
      s.exitstatus.must_equal 1
    end
  end
end
