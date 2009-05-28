require File.dirname(__FILE__) + '/test_helper.rb'

class TestMechaflickr < Test::Unit::TestCase
  def setup
    @mf = Mechaflickr.new(fixture_file('mechaflickr.yaml'))
  end
  
  def expect_api_call method, options
    @mf.agent.expects(:get).with(Mechaflickr.ENDPOINT, 
      { 'api_sig' => @mf.config['api_sig'],
        'api_key' => @mf.config['api_key'],
        'method'  => method }.merge(options))
  end
  
  def test_can_retrieve_frob
    agent.expects(:get).with(Mechaflickr).returns("bob")
    assert_match /\w+-\w+-\w+/, @mf.frob
  end
  
  def test_can_get_token
    assert_match /\w+-\w+/, @mf.auth_token
  end
  
  def test_can_upload
    photo = @mf.upload(fixture_file('exampleimage.jpg'), 'title' => 'test', 
                                                         'description' => 'just a test', 
                                                         'tags' => ('test ' + Time.now.strftime('%Y%m%d')))
    assert photo.is_a?(Mechaflickr::Photo)
  end
  
  def test_can_create_set_with_multiple_pictures
    photos = %w(exampleimage.jpg exampleimage2.jpg exampleimage3.jpg).map do |i|
      @mf.upload(fixture_file(i), 'title' => i, 'description' => 'just a test')
    end
    photoset = @mf.create_set('test set', photos, 'just a test set')
    assert photoset.is_a?(Mechaflickr::Photoset)
  end
  
  def test_supports_optional_logging
    fail
  end
  
  def test_can_upload_descriptions_with_html_entities
    fail
    # try it with &yen;, \xE3\x81\xBF\xE3\x81\x9F\xE3\x81\xBE (japanese mixed in with english)
  end
  
  def test_raises_sensible_exception_when_making_empty_sets
    fail
  end
end
