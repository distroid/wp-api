module WP::API
  class Configuration
    attr_accessor :host, :scheme, :username, :password, :endpoint,
                  :consumer_key, :consumer_secret, :oauth_token,
                  :oauth_token_secret, :proxy_host, :proxy_port,
                  :proxy_username, :proxy_password

    def client_setup_hash
      {
        host: host,
        scheme: scheme,
      }
    end

    def basic_auth_hash
      {
        username: username,
        password: password
      }
    end

    def basic_auth?
      !username.nil? || !password.nil?
    end

    def oauth_hash
      {
        consumer_key:       consumer_key,
        consumer_secret:    consumer_secret,
        oauth_token:        oauth_token,
        oauth_token_secret: oauth_token_secret
      }
    end

    def oauth?
      !consumer_key.nil?      &&
        !consumer_secret.nil? &&
        !oauth_token.nil?     &&
        !oauth_token_secret.nil?
    end

    def proxy_hash
      {
        proxy_host:     proxy_host,
        proxy_port:     proxy_port,
        proxy_username: proxy_username,
        proxy_password: proxy_password
      }
    end

    def via_proxy?
      !proxy_host.nil? && !proxy_port.nil?
    end
  end
end
