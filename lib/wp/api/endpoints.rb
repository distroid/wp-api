# frozen_string_literal: true

module WP::API
  module Endpoints
    def posts(query = {})
      resources('posts', query)
    end

    def post(id, query = {})
      resource('posts', id, query)
    end

    def create_post(data = {})
      resource_post('posts', nil, data)
    end

    def update_post(id, data = {})
      resource_post('posts', id, data)
    end

    def delete_post(id, data = {})
      resource_delete('posts', id, data)
    end

    def post_named(slug)
      resource_named('posts', slug)
    end

    def post_meta(id, query = {})
      resource_subpath('posts', id, 'meta', query).first
    end

    def comments(query = {})
      resources('comments', query)
    end

    def comment(id, query = {})
      resource('comments', id, query)
    end

    def create_comment(data = {})
      resource_post('comments', nil, data)
    end

    def category(id, query = {})
      resource('categories', id, query)
    end

    def categories(query = {})
      resources('categories', query)
    end

    def create_category(data = {})
      resource_post('categories', nil, data)
    end

    def tag(id, query = {})
      resource('tags', id, query)
    end

    def tags(query = {})
      resources('tags', query)
    end

    def pages(query = {})
      resources('pages', query)
    end

    def page(id, query = {})
      resource('pages', id, query)
    end

    def page_named(slug)
      resource_named('pages', slug)
    end

    def item_named(slug)
      item = resource_named('posts', slug)
    rescue WP::API::ResourceNotFoundError
      item = resource_named('pages', slug)
    end

    def users(query = {})
      resources('users', query)
    end

    def user(id, query = {})
      resource('users', id, query)
    end

    def update_user(id, data = {})
      resource_post('users', id, data)
    end

    def media(id, query = {})
      resource('media', id, query)
    end

    def medias(query = {})
      resources('media', query)
    end

    def info
      resources, headers = get_request('', base_path: 'wp-json')
      build_resource('info', resources, headers)
    end

    def settings(query = {})
      resource('settings', query)
    end

    def update_settings(query)
      resource_post('settings', nil, query)
    end

    def types(query = {})
      resources('types', query)
    end

    def taxonomies(query = {})
      resources('taxonomies', query)
    end

    def taxonomy(id, query = {})
      resource('taxonomies', id, query)
    end

    def custom_types(type, query = {})
      resources(type, query)
    end

    def custom_type(type, id, query = {})
      resource(type, id, query)
    end

    private

    def resources(res, query = {})
      resources, headers = get_request(res, query)
      resources.collect do |hash|
        build_resource(res, hash, headers)
      end
    end

    def resource(res, id = nil, query = {})
      path = id ? "#{res}/#{id}" : res.to_s
      resources, headers = get_request(path, query)
      build_resource(res, resources, headers)
    end

    def sub_resources(res, sub, query = {})
      resources, headers = get_request("#{res}/#{sub}", query)
      resources.collect do |hash|
        build_resource(sub, hash, headers)
      end
    end

    def resource_post(res, id = nil, data = {})
      path = id ? "#{res}/#{id}" : res.to_s
      resources, headers = post_request(path, data)
      build_resource(res, resources, headers)
    end

    def resource_delete(res, id, data = {})
      resources, headers = delete_request("#{res}/#{id}", data)
      build_resource(res, resources, headers)
    end

    def resource_subpath(res, id, subpath, query = {})
      query.merge(should_raise_on_empty: false)
      resources, headers = get_request("#{res}/#{id}/#{subpath}", query)
      resource_name = subpath.split('/').last
      resources.collect do |hash|
        build_resource(resource_name, hash, headers)
      end
    end

    def build_resource(resource_name, data, headers)
      klass = resource_class(resource_name)
      klass ? klass.new(data, headers) : data
    end

    def resource_named(res, slug)
      resources(res, name: slug).first
    end

    def resource_class(res)
      WP::API.const_get(res.classify)
    rescue NameError
      nil
    end
  end
end
