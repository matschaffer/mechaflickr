require 'test/unit'
require File.dirname(__FILE__) + '/../lib/mechaflickr'

class Test::Unit::TestCase
  def fixture_file name
    File.join(File.dirname(__FILE__), 'fixtures', name)
  end
end