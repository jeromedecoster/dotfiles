
# jpeg executable with quality option -1 to -4
describe 'jpeg executable' do

  before do
    `rm -fr #{SUPPORT}/jpeg`
    `mkdir -p #{SUPPORT}/jpeg`
    Dir.chdir "#{SUPPORT}/assets/jpeg"
  end
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'should create progressive mobile low jpeg' do
    # skip

    1.upto(4) do |i|
      o, e, s = Open3.capture3 "jpeg -#{i} -w sfw-75p-nothing.jpg -o '#{SUPPORT}/jpeg'"
      o.strip.wont_be_empty
      e.strip.must_be_empty
      s.exitstatus.must_equal 0

      # indice must be 1.0 and must be progressive
      o, s = Open3.capture2 "jpeg -a -w '#{SUPPORT}/jpeg/sfw-75p-nothing.jpg'"
      arr = o.strip.split
      arr[0].must_equal "#{i}.0"
      arr[5].must_equal 'g'
      s.exitstatus.must_equal 0

      # must not have extra datas
      arr[6].must_equal '-'
    end
  end

  it 'should create baseline mobile low jpeg' do
    # skip

    1.upto(4) do |i|
      o, e, s = Open3.capture3 "jpeg -#{i} -n -w sfw-75p-nothing.jpg -o '#{SUPPORT}/jpeg'"
      o.strip.wont_be_empty
      e.strip.must_be_empty
      s.exitstatus.must_equal 0

      # indice must be 1.0 and must be progressive
      o, s = Open3.capture2 "jpeg -a -w '#{SUPPORT}/jpeg/sfw-75p-nothing.jpg'"
      arr = o.strip.split
      arr[0].to_f.must_be_close_to i, 0.3
      arr[5].must_equal '-'
      s.exitstatus.must_equal 0

      # must not have extra datas
      arr[6].must_equal '-'
    end
  end
end
