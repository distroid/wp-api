require 'httparty'
require 'addressable/uri'
require 'wp/api/endpoints'
require 'wp/api/oauth1'
require 'active_support/hash_with_indifferent_access'

module WP::API
  class Client
    include HTTParty
    include Endpoints
    attr_reader :args

    default_options.update(verify: false)

    attr_accessor :host

    DIRECT_PARAMS = %w[type context filter].freeze

    def initialize(args = {})
      @scheme = args.dig(:scheme)
      @host = args.dig(:host)
      @basic_auth = {}
      @proxy = {}
      @oauth = nil
      fail ':host is required' unless host.is_a?(String) && host.length > 0
    end

    def inspect
      to_s.sub(/>$/, '') + " @scheme=\"#{@scheme}\" @host=\"#{@host}\" @basic_auth=\"#{!@basic_auth.empty?}\" @oauth=\"#{!@oauth.nil?}\">"
    end

    def basic_auth
      {
        username: WP::API.configuration.username,
        password: WP::API.configuration.password
      }
    end

    def set_proxy(proxy_host:, proxy_port:, proxy_username:, proxy_password:)
      @proxy = {
        http_proxyaddr: proxy_host,
        http_proxyport: proxy_port,
        http_proxyuser: proxy_username,
        http_proxypass: proxy_password
      }.compact
    end

    def oauth(consumer_key:, consumer_secret:, oauth_token:, oauth_token_secret:)
      @oauth = WP::API::Oauth1.new(
        consumer_key:       consumer_key,
        consumer_secret:    consumer_secret,
        oauth_token:        oauth_token,
        oauth_token_secret: oauth_token_secret
      )
    end

    protected

    def authenticate?
      WP::API.configuration.basic_auth?
    end

    def get(resource, query = {})
      should_raise_on_empty = query.delete(:should_raise_on_empty) { true }
      query = ActiveSupport::HashWithIndifferentAccess.new(query)
      path = url_for(resource, query)
      options = {}
      options.merge!(basic_auth).deep_stringify_keys if authenticate?
      response = Client.get(path, options)

      if response.code != 200
        return [[], response.headers] if response.parsed_response['code'] == 'rest_post_invalid_page_number'
        raise WP::API::ResourceNotFoundError.new('Invalid HTTP code (' + response.code.to_s + ') for ' + path)
      elsif response.parsed_response.empty? && should_raise_on_empty
        raise WP::API::ResourceNotFoundError.new('Empty responce for ' + path)
      else
        [response.parsed_response, response.headers]
      end
    end
    alias get_request get

    def post_request(resource, data = {})
      should_raise_on_empty = data.delete(:should_raise_on_empty) { true }

      path = url_for(resource, {})
      options = request_options('post', path, data)
      options[:body] = data

      response = Client.post(path, options)
      if !(200..201).include? response.code
        raise WP::API::ResourceNotFoundError.new('Invalid HTTP code (' + response.code.to_s + ') for ' + path)
      elsif (response.parsed_response.nil? || response.parsed_response.empty?) && should_raise_on_empty
        raise WP::API::ResourceNotFoundError.new('Empty responce for ' + path)
      else
        [ response.parsed_response, response.headers ]
      end
    end

    def delete_request(resource, data = {})
      should_raise_on_empty = data.delete(:should_raise_on_empty) { true }

      path = url_for(resource, {})
      options = request_options('delete', path, data)
      response = Client.delete(path, options)
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
      result = {}
      result[:basic_auth] = @basic_auth unless @basic_auth.empty?
      result.merge!(@proxy) unless @proxy.empty?
      unless @oauth.nil?
        result[:headers] = { 'Authorization' => @oauth.auth_header(http_method: http_method, url: request_url, params: params) }
      end
      result
    end

    def url_for(fragment, query)
      base = query.delete(:base_path)
      base ||= 'wp-json/wp/v2'
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
