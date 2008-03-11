$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'hpricot'
require 'digest/md5'
require 'yaml'

class Mechaflickr
  ENDPOINT = 'http://api.flickr.com/services/rest/'
  AUTH = 'http://flickr.com/services/auth/'
  
  attr_accessor :authorization
  
  def initialize(config_file)
    @config_file = config_file
    @config = YAML::load_file(@config_file)
    @config.each { |k, v| instance_variable_set("@#{k}", v) }
    
    @agent = WWW::Mechanize.new
    @agent.set_proxy(@proxy['host'], @proxy['port']) if @proxy
    
    @authorization = proc { |u| default_authorization(u) }
  end
  
  def frob
    @frob ||= api_call('flickr.auth.getFrob').search('frob').inner_html
  end
  
  def token
    if @token.nil?
      authorize
      @token = api_call('flickr.auth.getToken', 'frob' => frob).search('token').inner_html
      @config['token'] = @token
      File.open(@config_file, 'w') { |f| f.print @config.to_yaml }
    end
    
    @token
  end
  
  def authorize
    args = { 'api_key' => @api_key, 'perms' => @perms, 'frob' => frob }
    uri = AUTH + '?' + WWW::Mechanize.build_query_string(sign(args))
    @authorization.call(uri)
  end
  
  def default_authorization(uri)
    `open "#{uri}"`
    puts "Press enter after you authorize this script."
    gets
  end
  
  private
  def api_call(method, args = {})
    args = args.merge('method' => method, 'api_key' => @api_key)
    response = @agent.get(ENDPOINT + '?' + WWW::Mechanize.build_query_string(sign(args)))
    Hpricot(response.body)
  end
  
  def sign(args)
    concatenation = args.keys.sort.map { |k| k.to_s + args[k].to_s }.join
    signature = Digest::MD5.hexdigest(@secret + concatenation)
    args.merge('api_sig' => signature)
  end
end