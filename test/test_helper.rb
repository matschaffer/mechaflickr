require 'test/unit'
require File.dirname(__FILE__) + '/../lib/mechaflickr'
require 'mocha'

class Test::Unit::TestCase
  def fixture_path name
    File.join(File.dirname(__FILE__), 'fixtures', name)
  end
  
  def fixture_file name
    File.new(fixture_path(name))
  end
  
  def response name
    fixture_file(File.join('responses', "#{name}.xml")).read
  end
end