require File.dirname(__FILE__) + '/test_helper.rb'

class TestMechaflickr < Test::Unit::TestCase
  def setup
    @mf = Mechaflickr.new(fixture_file('mechaflickr.yaml'))
  end
  
  def test_can_retrieve_frob
    assert_match /\w+-\w+-\w+/, @mf.frob
  end
  
  def test_can_get_token
    assert_match /\w+-\w+/, @mf.auth_token
  end
  
  def test_can_upload
    photo = @mf.upload(fixture_file('exampleimage.jpg'), 'title' => 'test', 'description' => 'just a test')
    assert photo.is_a?(Mechaflickr::Photo)
  end
  
  def test_can_create_set
    photo = @mf.upload(fixture_file('exampleimage.jpg'), 'title' => 'test', 'description' => 'just a test')
    photoset = @mf.create_set('test set', [photo], 'just a test set')
    assert photoset.is_a?(Mechaflickr::Photoset)
  end
end
