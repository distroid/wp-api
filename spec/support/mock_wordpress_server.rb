# frozen_string_literal: true

require 'fakeweb'

class MockWordpressServer
  include FilesHelper

  attr_reader :host

  def initialize(host: 'wp.example.com')
    @host = host

    register_all
  end

  protected

  def register_all
    FakeWeb.register_uri(
      :get,
      "http://#{host}/wp-json/wp/v2/posts",
      body: support_file('posts.json'),
      content_type: 'application/json',
      link: support_file('posts.header.txt')
    )
    register_posts
    register_resource('users', 1)
    register_resource('categories', 1)
  end

  def register_posts
    [1, 2].map do |record_id|
      register_resource('posts', record_id)
    end
  end

  def register_resource(resource_name, record_id)
    FakeWeb.register_uri(
      :get,
      "http://#{host}/wp-json/wp/v2/#{resource_name}/#{record_id}",
      body: support_file("#{resource_name}/#{record_id}.json"),
      content_type: 'application/json'
    )
  end
end
