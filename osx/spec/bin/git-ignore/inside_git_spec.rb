
# inside a git directory
describe 'git-ignore extension' do

  let(:git)      { "#{SUPPORT}/gitignore/git" }
  # important: each opened IO must be properly closed within each test
  let(:gig)      { IO.popen 'git ignore', 'r+' }
  let(:lines)    { File.readlines("#{git}/.gitignore").map!{ |e| e.strip } }
  let(:patterns) { %w{.DS_Store desktop.ini Thumbs.db .DocumentRevisions-V100/
                      .fseventsd/ .Spotlight-V100/ .svn/ .TemporaryItems/
                      .Trash/ .Trashes/ node_modules/} }

  before do
    `rm -fr #{SUPPORT}/gitignore`
    `mkdir -p "#{git}"`
    `cp -r "#{SUPPORT}/assets/git-simple/" "#{git}"`
    Dir.chdir "#{git}/path/to/directory"
  end
  # see after tip above
  after  { Dir.chdir '/' }

  # reply 'n' to 'create .gitignore file? [Yn]'
  it 'reply n' do
    # skip

    gig.puts 'n'
    # readlines help to close the console action without 'error: git-ignore died of signal 13'
    arr = gig.readlines
    gig.close

    arr.size.must_equal 1
    # escape colored stdout with '.*' before and after '.gitignore'
    arr[0].must_match /^create .*\.gitignore.* file.*/

    File.exist?("{git}/.gitignore").must_equal false
  end

  # reply 'y' then 'n' should create gitignore file without add it
  it 'reply y then n' do
    # skip

    gig.puts 'y'
    gig.puts 'n'
    # see readlines tip above
    gig.readlines
    gig.close

    File.exist?("#{git}/.gitignore").must_equal true

    # the default patterns must be included
    patterns.each do |e|
      lines.include?(e).must_equal true
    end

    Dir.chdir "#{git}"
    o, e, s = Open3.capture3 'git ls-files .gitignore --error-unmatch &>/dev/null'
    # the gitignore file must not be added to the git repository
    s.exitstatus.must_equal 1
  end

  # reply 'y' then 'y' should create gitignore file and add it
  it 'reply y then y' do
    # skip

    gig.puts 'y'
    gig.puts 'y'
    # see readlines tip above
    gig.readlines
    gig.close

    Dir.chdir "#{git}"
    o, e, s = Open3.capture3 'git ls-files .gitignore --error-unmatch &>/dev/null'
    # the gitignore file must be added to the git repository
    s.exitstatus.must_equal 0

    # override gig with a new call
    gig = IO.popen 'git ignore gi .DS_Store joe .DS_Stored', 'r+'
    gig.puts 'n'
    gig.readlines
    gig.close

    patterns.concat %w{gi joe .DS_Stored}
    # the default patterns + gi, joe and .DS_Stored must be included
    patterns.each do |e|
      lines.include?(e).must_equal true
    end

    # an already existing pattern must not be included again
    patterns.count('.DS_Store').must_equal 1
  end
end
