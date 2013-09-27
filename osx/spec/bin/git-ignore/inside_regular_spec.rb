
# inside a non git directory
describe 'git-ignore extension' do

  let(:regular) { "#{SUPPORT}/gitignore/regular" }

  before do
    `rm -fr #{SUPPORT}/gitignore`
    `mkdir -p "#{regular}/path/to/directory"`
    Dir.chdir "#{regular}/path/to/directory"
  end
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'must fails' do
    # skip

    o, e, s = Open3.capture3 'git ignore'
    o.must_be_empty
    e.strip.must_equal 'fatal: Not a git repository (or any of the parent directories): .git'
    s.exitstatus.must_equal 128
  end
end
