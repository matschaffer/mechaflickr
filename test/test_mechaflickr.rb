require File.dirname(__FILE__) + '/test_helper.rb'

class TestMechaflickr < Test::Unit::TestCase
  def setup
    @mf = Mechaflickr.new('mechaflickr.yaml')
  end
  
  def test_can_retrieve_frob
    assert_match /\w+-\w+-\w+/, @mf.frob
  end
  
  def test_can_get_token
    assert_match /\w+-\w+/, @mf.token
  end
end
