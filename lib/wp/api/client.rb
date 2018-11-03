# frozen_string_literal: true

require 'httparty'
require 'addressable/uri'
require 'wp/api/endpoints'
require 'wp/api/oauth1'
require 'active_support/hash_with_indifferent_access'

module WP::API
  class Client
    include HTTParty
    include Endpoints

    HTTP_METHOD_GET = 'get'.freeze
    HTTP_METHOD_POST = 'post'.freeze
    HTTP_METHOD_DELETE = 'delete'.freeze

    default_options.update(verify: false)

    attr_reader :host, :scheme, :proxy, :basic_auth

    DIRECT_PARAMS = %w[type context filter].freeze

    def initialize(host:, **args)
      @scheme = args.fetch(:scheme, 'http')
      @host = host
      @basic_auth = args.fetch(:basic_auth, {})
      @proxy = args.fetch(:proxy, {})
      @oauth = nil

      raise ':host is required' unless host.is_a?(String) && !host.empty?
    end

    def inspect
      to_s.sub(/>$/, '') + " @scheme=\"#{@scheme}\" @host=\"#{@host}\" @basic_auth=\"#{!@basic_auth.empty?}\" @oauth=\"#{!@oauth.nil?}\">"
    end

    def set_basic_auth(username:, password:)
      @basic_auth = { username: username, password: password }
    end

    def set_proxy(proxy_host:, proxy_port:, proxy_username: nil, proxy_password: nil)
      @proxy = {
        http_proxyaddr: proxy_host,
        http_proxyport: proxy_port,
        http_proxyuser: proxy_username,
        http_proxypass: proxy_password
      }.compact
    end

    def set_oauth(consumer_key:, consumer_secret:, oauth_token:, oauth_token_secret:)
      @oauth = WP::API::Oauth1.new(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        oauth_token: oauth_token,
        oauth_token_secret: oauth_token_secret
      )
    end

    protected

    def get_request(resource, data = {})
      should_raise_on_empty = data.delete(:should_raise_on_empty) { true }

      path = build_request_path(resource, ActiveSupport::HashWithIndifferentAccess.new(data))
      options = request_options(HTTP_METHOD_GET, build_request_path(resource), data)

      verify_response(
        response: Client.get(path, options),
        http_method: HTTP_METHOD_GET,
        path: path,
        should_raise_on_empty: should_raise_on_empty
      )
    end

    def post_request(resource, data = {})
      should_raise_on_empty = data.delete(:should_raise_on_empty) { true }

      path = build_request_path(resource)
      options = request_options(HTTP_METHOD_POST, path, data)

      verify_response(
        response: Client.post(path, options.merge(body: data)),
        http_method: HTTP_METHOD_POST,
        path: path,
        should_raise_on_empty: should_raise_on_empty
      )
    end

    def delete_request(resource, data = {})
      should_raise_on_empty = data.delete(:should_raise_on_empty) { true }

      path = build_request_path(resource)
      options = request_options(HTTP_METHOD_DELETE, path, data)

      verify_response(
        response: Client.delete(path, options),
        http_method: HTTP_METHOD_DELETE,
        path: path,
        should_raise_on_empty: should_raise_on_empty
      )
    end

    private

    def request_options(http_method, request_url, params)
      result = {}
      result[:basic_auth] = basic_auth unless basic_auth.empty?
      result.merge!(proxy) unless proxy.empty?
      unless oauth.nil?
        result[:headers] = {
          'Authorization' => oauth.auth_header(
            http_method: http_method,
            url: request_url,
            params: params
          )
        }
      end
      result
    end

    def verify_response(response:, http_method:, path:,should_raise_on_empty: true)
      if response.code != 200 && http_method == HTTP_METHOD_GET
        return [[], response.headers] if response.parsed_response['code'] == 'rest_post_invalid_page_number'

        raise WP::API::ResourceNotFoundError, "Invalid HTTP code (#{response.code}) for #{path}"
      elsif !(200..201).cover?(response.code) && http_method != HTTP_METHOD_GET
        raise WP::API::ResourceNotFoundError, "Invalid HTTP code (#{response.code}) for #{path}"
      elsif response.parsed_response.blank? && should_raise_on_empty
        raise WP::API::ResourceNotFoundError, "Empty responce for #{path}: #{response.dig('message')}"
      else
        [response.parsed_response, response.headers]
      end
    end

    def build_request_path(fragment, query = {})
      base = query.delete(:base_path) { 'wp-json/wp/v2' }
      url = "#{scheme}://#{host}/#{base}/#{fragment}"
      return url if query.empty?
      url << ('?' + params(query))
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
