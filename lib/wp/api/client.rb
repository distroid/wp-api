require 'httparty'
require 'addressable/uri'
require 'wp/api/endpoints'
require 'active_support/hash_with_indifferent_access'

module WP::API
  class Client
    include HTTParty
    include Endpoints

    default_options.update(verify: false)

    attr_accessor :host

    DIRECT_PARAMS = %w(type context filter)

    def initialize(host:, scheme: 'http', user: nil, password: nil, v: 2)
      @scheme   = scheme
      @host     = host
      @user     = user
      @password = password
      @verison  = v

      fail ':host is required' unless host.is_a?(String) && host.length > 0
    end

    def inspect
      to_s.sub(/>$/, '') + " @scheme=\"#{@scheme}\" @host=\"#{@host}\" @user=\"#{@user}\" @password=#{@password.present?}>"
    end

    protected

    def get_request(resource, query = {})
      should_raise_on_empty = query.delete(:should_raise_on_empty) { true }
      query = ActiveSupport::HashWithIndifferentAccess.new(query)
      path = url_for(resource, query)

      response = if authenticate?
        Client.get(path, basic_auth: { username: @user, password: @password })
      else
        Client.get(path)
      end

      if response.code != 200
        raise WP::API::ResourceNotFoundError.new('Invalid HTTP code (' + response.code.to_s + ') for ' + path)
      elsif response.parsed_response.empty? && should_raise_on_empty
        raise WP::API::ResourceNotFoundError.new('Empty responce for ' + path)
      else
        [ response.parsed_response, response.headers ]
      end
    end

    def post_request(resource, data = {})
      should_raise_on_empty = data.delete(:should_raise_on_empty) || true
      path = url_for(resource, {})

      response = if authenticate?
        Client.post(path, { :body => data, basic_auth: { username: @user, password: @password } })
      else
        Client.post(path, { :body => data })
      end

      if !(200..201).include? response.code
        raise WP::API::ResourceNotFoundError.new('Invalid HTTP code (' + response.code.to_s + ') for ' + path)
      elsif (response.parsed_response.nil? || response.parsed_response.empty?) && should_raise_on_empty
        raise WP::API::ResourceNotFoundError.new('Empty responce for ' + path)
      else
        [ response.parsed_response, response.headers ]
      end
    end

    private

    def authenticate?
      @user && @password
    end

    def url_for(fragment, query)
      base = 'wp-json'
      base = 'wp-json/wp/v2' if @verison == 2
      url = "#{@scheme}://#{@host}/#{base}/#{fragment}"
      url << ("?" + params(query)) unless query.empty?

      url
    end

    def params(query)
      uri = Addressable::URI.new
      filter_hash = { page: query.delete('page') || 1 }
      query.each do |key, value|
        filter_hash[key] = value if DIRECT_PARAMS.include?(key) || key.include?('[')
        filter_hash[key] = value
      end
      uri.query_values = filter_hash

      uri.query
    end
  end
end
