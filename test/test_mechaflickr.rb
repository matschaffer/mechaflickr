require File.dirname(__FILE__) + '/test_helper.rb'

class TestMechaflickr < Test::Unit::TestCase
  def setup
    @mf = Mechaflickr.new(fixture_path('mechaflickr.yaml'))
    @mf.authorization = mock("Browser authorization")
  end
  
  def expect_api_call *args
    @mf.expects(:api_call).with(*args) 
  end
  
  def test_can_retrieve_frob
    expect_api_call('flickr.auth.getFrob').returns(response('flickr.auth.getFrob'))
    assert_match '72157618939351796-7f7570bc2a596c80-849278', @mf.frob
  end
  
  def test_can_get_token
    @mf.instance_variable_set('@auth_token', nil) # force reload of auth token
    @mf.authorization.expects('call') # Expect a call to the authorization method (usually opening a browser)

    expect_api_call('flickr.auth.getFrob').returns(response('flickr.auth.getFrob'))
    expect_api_call('flickr.auth.getToken',
                    'frob' => '72157618939351796-7f7570bc2a596c80-849278').returns(response('flickr.auth.getToken'))
    assert_match /\w+-\w+/, @mf.auth_token
  end
  
  def test_can_upload
    photo = @mf.upload(fixture_path('exampleimage.jpg'), 'title' => 'test', 
                                                         'description' => 'just a test', 
                                                         'tags' => ('test ' + Time.now.strftime('%Y%m%d')))
    assert photo.is_a?(Mechaflickr::Photo)
  end
  
  def test_can_create_set_with_multiple_pictures
    photos = %w(exampleimage.jpg exampleimage2.jpg exampleimage3.jpg).map do |i|
      @mf.upload(fixture_path(i), 'title' => i, 'description' => 'just a test')
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
