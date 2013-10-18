
# jpeg executable without quality option
describe 'jpeg executable' do

  before do
    `rm -fr #{SUPPORT}/jpeg`
    `mkdir -p #{SUPPORT}/jpeg/path/to/directory`
    Dir.chdir "#{SUPPORT}/assets/jpeg"
  end
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'should create progressive jpeg without option n' do
    # skip

    o, e, s = Open3.capture3 "jpeg -w sfw-75p-nothing.jpg -o '#{SUPPORT}/jpeg'"
    o.strip.wont_be_empty
    e.strip.must_be_empty
    s.exitstatus.must_equal 0

    # must be progressive
    o, s = Open3.capture2 "jpeg -a -w '#{SUPPORT}/jpeg/sfw-75p-nothing.jpg'"
    o.strip.split[5].must_equal 'g'
    s.exitstatus.must_equal 0

    # must not have extra datas
    o.strip.split[6].must_equal '-'
  end

  it 'should create baseline jpeg with option n' do
    # skip

    o, e, s = Open3.capture3 "jpeg -n -w sfw-75p-nothing.jpg -o '#{SUPPORT}/jpeg'"
    o.strip.wont_be_empty
    e.strip.must_be_empty
    s.exitstatus.must_equal 0

    o, s = Open3.capture2 "jpeg -a -w '#{SUPPORT}/jpeg/sfw-75p-nothing.jpg'"
    o.strip.split[5].must_equal '-'
    s.exitstatus.must_equal 0

    # must not have extra datas
    o.strip.split[6].must_equal '-'
  end
end
