
def indice cmd
  Open3.capture2(cmd)[0].split[0]
end

def percentage cmd, idx
  Open3.capture2(cmd)[0].split[idx]
end

# jpeg executable with option -a
describe 'jpeg executable' do

  before { Dir.chdir "#{SUPPORT}/assets/jpeg" }
  # prevent the error 'shell-init: error retrieving current directory: getcwd ...'
  after  { Dir.chdir '/' }

  it 'progressive detection' do
    # skip

    o, s = Open3.capture2 'jpeg -a -w sfw-75p-progressive.jpg'
    o.strip.split[5].must_equal 'g'
    s.exitstatus.must_equal 0

    o, s = Open3.capture2 'jpeg -a -w sfw-75p-nothing.jpg'
    o.strip.split[5].must_equal '-'
    s.exitstatus.must_equal 0
  end

  it 'color profile detection' do
    # skip

    o, s = Open3.capture2 'jpeg -a -w sfw-75p-progressive.jpg'
    o.strip.split[6].must_equal 'f'
    s.exitstatus.must_equal 0

    o, s = Open3.capture2 'jpeg -a -w convert-75p-strip.jpg'
    o.strip.split[6].must_equal '-'
    s.exitstatus.must_equal 0
  end

  it 'indice' do
    # skip

    indice('jpeg -a -w jpeg-q4.jpg').must_equal '4.0'

    indice('jpeg -a -p -w jpeg-q4-progressive.jpg').must_equal '4.0'

    indice('jpeg -a -w jpeg-q3.jpg').must_equal '3.0'

    indice('jpeg -a -p -w jpeg-q3-progressive.jpg').must_equal '3.0'

    indice('jpeg -a -w jpeg-q2.jpg').must_equal '2.0'

    indice('jpeg -a -p -w jpeg-q2-progressive.jpg').must_equal '2.0'

    indice('jpeg -a -w jpeg-q1.jpg').must_equal '1.0'

    indice('jpeg -a -p -w jpeg-q1-progressive.jpg').must_equal '1.0'

    indice('jpeg -a -p -w convert-25p.jpg').to_f.must_be :<, 1.0

    indice('jpeg -a -p -w sfw-75p-nothing.jpg').to_f.must_be :>, 4.0
  end

  it 'percentage' do
    # skip

    percentage('jpeg -a -w jpeg-q4.jpg', 1).to_f.must_be :<, 0

    percentage('jpeg -a -w jpeg-q4.jpg', 4).must_equal '0.0'

    percentage('jpeg -a -w jpeg-q1.jpg', 1).must_equal '0.0'

    percentage('jpeg -a -w jpeg-q1.jpg', 4).to_f.must_be :>, 0
  end

  it 'wrong format must be detected' do
    # skip

    o, e, s = Open3.capture3 'jpeg -a -w path/to/directory/gif-fake.jpg'
    o.strip.must_be_empty
    e.strip.must_match /is not valid$/
    s.exitstatus.must_equal 1

    o, e, s = Open3.capture3 'jpeg -a -w path/to/directory/png-fake.jpg'
    o.strip.must_be_empty
    e.strip.must_match /is not valid$/
    s.exitstatus.must_equal 1
  end

  it 'recursion must work' do
    # skip

    o, e, s = Open3.capture3 'jpeg -a -r -w path/to'
    o.strip.split("\n").size.must_equal 1
    e.strip.split("\n").size.must_equal 2
    s.exitstatus.must_equal 1
  end
end
