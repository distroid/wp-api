require 'wp/api/version'
require 'wp/api/configuration'
require 'wp/api/errors'
require 'wp/api/resource'
Dir[File.expand_path(File.dirname(__FILE__) + '/api/resources/*.rb')].each { |resource| require resource }
require 'wp/api/client'
require 'httparty'
require 'pry'
require 'httplog'

module WP
  module API
    class << self
      attr_accessor :configuration

      def configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end

      def [](host)
        Client.new(host: host)
      end

      def client
        @client ||= begin
          client = Client.new(configuration.client_setup_hash)
          client.basic_auth(configuration.basic_auth_hash) if configuration.basic_auth?
          client.oauth(configuration.oauth_hash)           if configuration.oauth? && !configuration.basic_auth?
          client.set_proxy(configuration.proxy_hash)       if configuration.via_proxy?
          client
        end
      end

      def reset!
        @client = nil
      end
    end
  end
end
