require 'httparty'
require 'addressable/uri'
require 'wp/api/endpoints'
require 'wp/api/oauth1'
require 'active_support/hash_with_indifferent_access'

module WP::API
  class Client
    include HTTParty
    include Endpoints

    default_options.update(verify: false)

    attr_accessor :host

    DIRECT_PARAMS = %w(type context filter)

    def initialize(host:, scheme: 'http')
      @scheme     = scheme
      @host       = host
      @basic_auth = {}
      @oauth      = nil

      fail ':host is required' unless host.is_a?(String) && host.length > 0
    end

    def inspect
      to_s.sub(/>$/, '') + " @scheme=\"#{@scheme}\" @host=\"#{@host}\" @basic_auth=\"#{!@basic_auth.empty?}\" @oauth=\"#{!@oauth.nil?}\">"
    end

    def basic_auth(username:, password:)
      @basic_auth = {username: username, password: password}
    end

    def oauth(consumer_key:, consumer_secret:, oauth_token:, oauth_token_secret:)
      @oauth = WP::API::Oauth1.new(consumer_key: consumer_key, consumer_secret: consumer_secret, oauth_token: oauth_token, oauth_token_secret: oauth_token_secret)
    end

    protected

    def get_request(resource, query = {})
      should_raise_on_empty = query.delete(:should_raise_on_empty) { true }
      path    = url_for(resource, ActiveSupport::HashWithIndifferentAccess.new(query))
      options = request_options('get', url_for(resource, {}), query)

      response = Client.get(path, options)
      if response.code != 200
        raise WP::API::ResourceNotFoundError.new('Invalid HTTP code (' + response.code.to_s + ') for ' + path)
      elsif response.parsed_response.empty? && should_raise_on_empty
        raise WP::API::ResourceNotFoundError.new('Empty responce for ' + path)
      else
        [ response.parsed_response, response.headers ]
      end
    end

    def post_request(resource, data = {})
      should_raise_on_empty = data.delete(:should_raise_on_empty) { true }

      path           = url_for(resource, {})
      options        = request_options('post', path, data)
      options[:body] = data

      response       = Client.post(path, options)
      if !(200..201).include? response.code
        raise WP::API::ResourceNotFoundError.new('Invalid HTTP code (' + response.code.to_s + ') for ' + path + ': ' + response.dig('message'))
      elsif (response.parsed_response.nil? || response.parsed_response.empty?) && should_raise_on_empty
        raise WP::API::ResourceNotFoundError.new('Empty responce for ' + path)
      else
        [ response.parsed_response, response.headers ]
      end
    end

    private

    def request_options(http_method, request_url, params)
      result              = {}
      result[:basic_auth] = @basic_auth unless @basic_auth.empty?
      unless @oauth.nil?
        result[:headers]  = { 'Authorization' => @oauth.auth_header(http_method: http_method, url: request_url, params: params) }
      end
      result
    end

    def url_for(fragment, query)
      base = 'wp-json/wp/v2'
      url = "#{@scheme}://#{@host}/#{base}/#{fragment}"
      url << ("?" + params(query)) unless query.empty?

      url
    end

    def params(query)
      uri = Addressable::URI.new
      filter_hash = {}
      query.each do |key, value|
        filter_hash[key] = value if DIRECT_PARAMS.include?(key) || key.include?('[')
        filter_hash[key] = value
      end
      uri.query_values = filter_hash

      uri.query
    end
  end
end
