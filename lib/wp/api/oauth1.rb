module WP::API
  class Oauth1
    def initialize(consumer_key:, consumer_secret:, oauth_token:, oauth_token_secret:)
      @consumer_key       = consumer_key
      @consumer_secret    = consumer_secret
      @oauth_token        = oauth_token
      @oauth_token_secret = oauth_token_secret
    end

    def auth_header(http_method:, url:, params:)
      oauth_params = {
        'oauth_consumer_key'     => @consumer_key,
        'oauth_token'            => @oauth_token,
        'oauth_nonce'            => SecureRandom.hex,
        'oauth_signature_method' => 'HMAC-SHA1',
        'oauth_timestamp'        => Time.now.getutc.to_i.to_s,
        'oauth_version'          => '1.0'
      }
      params                          = params.merge(oauth_params)
      base_string                     = signature_string(http_method, url, params)
      oauth_params['oauth_signature'] = sign(key, base_string)

      header(oauth_params)
    end

    protected

    def url_encode(input)
      ERB::Util.url_encode(input).gsub('%7E', '~')
    end

    def header(params)
      'OAuth ' + params.map{|name, value| "#{name}=\"#{value}\""}.join(', ')
    end

    def signature_string(http_method, url, params)
      sorted_params = params.sort.collect{|name, value| name + '=' + url_encode(value.to_s)}.join('&')
      [http_method.upcase, url, sorted_params].map{ |value| CGI.escape(value) }.join('&')
    end

    def key
      @consumer_secret + '&' + @oauth_token_secret
    end

    def sign(key, base_string)
      digest = OpenSSL::Digest.new('sha1')
      hmac   = OpenSSL::HMAC.digest(digest, key, base_string)
      CGI.escape Base64.encode64(hmac).chomp.gsub(/\n/, '')
    end
  end
end