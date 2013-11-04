
# jpeg executable with quality option -1 to -4
describe 'jpeg executable' do

  before do
    `rm -fr #{SUPPORT}/jpeg`
    `mkdir -p #{SUPPORT}/jpeg`
    Dir.chdir "#{SUPPORT}/assets/jpeg"
  end
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'should create progressive mobile low to desktop high jpeg' do
    # skip

    1.upto(4) do |i|
      o, e, s = Open3.capture3 "jpeg -#{i} -p -w sfw-75p-nothing.jpg -d '#{SUPPORT}/jpeg'"
      o.strip.wont_be_empty
      e.strip.must_be_empty
      s.exitstatus.must_equal 0

      # indice must be close to 1.0 ... 4.0 and must be progressive
      o, s = Open3.capture2 "jpeg -a -w '#{SUPPORT}/jpeg/sfw-75p-nothing.jpg'"
      arr = o.strip.split
      arr[0].to_f.must_be_close_to i, 0.35
      arr[5].must_equal 'g'
      s.exitstatus.must_equal 0

      # must not have extra datas
      arr[6].must_equal '-'
    end
  end

  it 'should create baseline mobile low to desktop high jpeg' do
    # skip

    1.upto(4) do |i|
      o, e, s = Open3.capture3 "jpeg -#{i} -w sfw-75p-nothing.jpg -d '#{SUPPORT}/jpeg'"
      o.strip.wont_be_empty
      e.strip.must_be_empty
      s.exitstatus.must_equal 0

      # indice must be 1.0 ... 4.0 and wont be progressive
      o, s = Open3.capture2 "jpeg -a -w '#{SUPPORT}/jpeg/sfw-75p-nothing.jpg'"
      arr = o.strip.split
      arr[0].must_equal "#{i}.0"
      arr[5].must_equal '-'
      s.exitstatus.must_equal 0

      # must not have extra datas
      arr[6].must_equal '-'
    end
  end

  it 'should work with option -d' do
    # skip

    `rm -fr #{SUPPORT}/jpeg/path/to/sfw-75p-nothing.jpg`
    `mkdir -p #{SUPPORT}/jpeg/path/to/directory`
    o, e, s = Open3.capture3 "jpeg -4 -w sfw-75p-nothing.jpg -d '#{SUPPORT}/jpeg/path/to'"
    o.strip.wont_be_empty
    e.strip.must_be_empty
    s.exitstatus.must_equal 0

    o, s = Open3.capture2 "jpeg -a -w '#{SUPPORT}/jpeg/path/to/sfw-75p-nothing.jpg'"
    arr = o.strip.split
    arr[0].must_equal '4.0'
  end

  it 'should work with option -o' do
    # skip

    `rm -fr #{SUPPORT}/jpeg/path/to/target.jpg`
    `mkdir -p #{SUPPORT}/jpeg/path/to/directory`
    o, e, s = Open3.capture3 "jpeg -4 -w sfw-75p-nothing.jpg -o '#{SUPPORT}/jpeg/path/to/target.jpg'"
    o.strip.wont_be_empty
    e.strip.must_be_empty
    s.exitstatus.must_equal 0

    o, s = Open3.capture2 "jpeg -a -w '#{SUPPORT}/jpeg/path/to/target.jpg'"
    arr = o.strip.split
    arr[0].must_equal '4.0'
  end
end
