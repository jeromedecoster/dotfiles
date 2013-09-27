
# crap detection inside a regular directory
describe 'crap executable' do

  let(:regular) { "#{SUPPORT}/crap/regular" }

  before do
    `rm -fr #{SUPPORT}/crap`
    add_crap regular
    Dir.chdir "#{regular}/path/to"
  end
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'with . or without path' do
    # skip

    ['', '.'].each do |path|
      arr = Open3.capture2("crap -c #{path}")[0].split "\n"
      arr.size.must_equal 12
      arr.each do |e|
        e.must_match /(\.DS_Store|\.fseventsd|\.Spotlight-V100|\.TemporaryItems|desktop.ini|Thumbs.db)$/
        e.wont_match /^\.\//
      end
    end
  end

  it 'with .. path' do
    # skip

    Dir.chdir "#{regular}/path/to/directory"
    %w{.. ../}.each do |path|
      arr = Open3.capture2("crap -c #{path}")[0].split "\n"
      arr.size.must_equal 12
      arr.each do |e|
        e.must_match /(\.DS_Store|\.fseventsd|\.Spotlight-V100|\.TemporaryItems|desktop.ini|Thumbs.db)$/
        # must starts with ../ (only 1 trailing slash)
        e.must_match /^\.\.\/[^\/]+/
      end
    end
  end

  it 'with directory path' do
    # skip

    %w{directory directory/}.each do |path|

      arr = Open3.capture2("crap -c #{path}")[0].split "\n"

      arr.size.must_equal 6
      arr.each do |e|
        e.must_match /(\.DS_Store|\.fseventsd|\.Spotlight-V100|\.TemporaryItems|desktop.ini|Thumbs.db)$/
        # must starts with directory/ (only 1 trailing slash)
        e.must_match /^directory\/[^\/]+/
      end
    end
  end
end
