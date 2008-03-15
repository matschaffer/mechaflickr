$:.unshift File.dirname(__FILE__)

require 'mechaflickr/photo'

require 'rubygems'
require 'ruby-debug'
require 'mechanize'
require 'hpricot'
require 'digest/md5'
require 'yaml'

class Mechaflickr
  ENDPOINT = 'http://api.flickr.com/services/rest/'
  AUTH = 'http://flickr.com/services/auth/'
  UPLOAD = 'http://api.flickr.com/services/upload/'
  
  attr_accessor :authorization
  attr_reader :api_key, :perms
  
  def initialize(config_file)
    @config_file = config_file
    @config = YAML::load_file(@config_file)
    @config.each { |k, v| instance_variable_set("@#{k}", v) }
    
    @agent = WWW::Mechanize.new
    @agent.set_proxy(@proxy['host'], @proxy['port']) if @proxy
    
    @authorization = method(:default_authorization).to_proc
  end
  
  def frob
    @frob ||= element('frob', api_call('flickr.auth.getFrob'))
  end
  
  def auth_token
    if @auth_token.nil?
      authorize
      @auth_token = element('token', api_call('flickr.auth.getToken', 'frob' => frob))
      @config['auth_token'] = @auth_token
      File.open(@config_file, 'w') { |f| f.print @config.to_yaml }
    end
    
    @auth_token
  end
  
  def authorize
    args = { 'api_key' => api_key, 'perms' => perms, 'frob' => frob }
    uri = AUTH + '?' + WWW::Mechanize.build_query_string(sign(args))
    @authorization.call(uri)
  end
  
  def default_authorization(uri)
    `open "#{uri}"`
    puts "Press enter after you authorize this script."
    gets
  end
  
  # Arguments:
  # 
  # path
  #   File system path for the file to upload.
  # 
  # Options (as string keys in a hash):
  #   title => The title of the photo.
  #   description => A description of the photo. May contain some limited HTML.
  #   tags => A space-seperated list of tags to apply to the photo.
  #   is_public, is_friend, is_family => Set to 0 for no, 1 for yes. Specifies who can view the photo.
  #   safety_level => Set to 1 for Safe, 2 for Moderate, or 3 for Restricted.
  #   content_type => Set to 1 for Photo, 2 for Screenshot, or 3 for Other.
  #   hidden => Set to 1 to keep the photo in global search results, 2 to hide from public searches.
  def upload(path, options)
    args = sign(auth(options))
    args['photo'] = File.new(path)
    Photo.new(element('photoid', @agent.post(UPLOAD, args).body))
  end
  
  private
  def api_call(method, args = {})
    args = args.merge('method' => method, 'api_key' => api_key)
    response = @agent.get(ENDPOINT, sign(args))
    response.body
  end
  
  def auth(args)
    args.merge('api_key' => @api_key, 'auth_token' => auth_token)
  end
  
  def sign(args)
    concatenation = args.keys.sort.map { |k| k.to_s + args[k].to_s }.join
    signature = Digest::MD5.hexdigest(@secret + concatenation)
    args.merge('api_sig' => signature)
  end
  
  def element(name, xml)
    Hpricot(xml).search(name).inner_html
  end
end