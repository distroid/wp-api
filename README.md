# WP::API for API v.2

[![Circle CI](https://circleci.com/gh/colinyoung/wp-api.png?style=badge)](https://circleci.com/gh/colinyoung/wp-api)

It is update original gem for compatibility with [WP REST API v2.0 (WP-API)](http://v2.wp-api.org/)

## Installation

    gem 'wp-api', git: "https://github.com/distroid/wp-api"
    bundle

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Usage

This gem can use the Basic Auth plugin, which will let you use a username/password to authenticate.
This plugin is available here: https://github.com/WP-API/Basic-Auth

This also needs exposed the custom post types on the REST API. This can be done with the REST API Controller plugin.


```ruby
client = WP::API['example.com']
# or
client = WP::API::Client.new(host: 'example.com')

# List all posts
client.posts

# Get post by ID
client.post(1) # => post object #1 (look to resources/post.rb)

# List all users
client.users

# Append parameters
client.posts(posts_per_page: 1000)

# Use basic auth set in inializer
client = WP::API::Client.new(
  host: 'example.com',
  basic_auth: { username: 'api', password: 'apipassword' }
)

# Use basic auth (used to access post meta) and https
client = WP::API::Client.new(host: 'example.com', scheme: 'https')
client.set_basic_auth(username: 'api', password: 'apipassword')
client.post_meta(1234) # => metadata for post #1234

# Use OAuth
client = WP::API::Client.new(host: 'example.com', scheme: 'https')
client.set_oauth(
  consumer_key:       'consumer_key',
  consumer_secret:    'consumer_secret',
  oauth_token:        'oauth_token',
  oauth_token_secret: 'oauth_token_secret'
)
client.post_meta(1234) # => metadata for post #1234

# use proxy for requests
client = WP::API::Client.new(host: 'example.com', scheme: 'https')
# username and password are optional
client.set_proxy(
  proxy_host: '127.0.0.1',
  proxy_port: 80,
  proxy_username: 'username',
  proxy_password: 'password'
)
client.post_meta(1234) # => metadata for post #1234

```

## Manage posts

```ruby
#List Posts
client.posts

#Create a Post
client.create_post(
  title: title,
  content: content,
  slug: slug,
  date: published_at,
  status: :publish,
  categories: [1]
)

#Retrieve a Post
client.post(1)

#Update a Post
client.update_post(
  1,
  {
    title: title,
    content: content,
    slug: slug,
    date: published_at,
    status: :publish,
    categories: [1]
  }
)

#Delete a Post
wrapper.delete_post(1, should_raise_on_empty: false)
```

## Site settings

```ruby
# For changes on site you should be authorized
client = WP::API::Client.new(host: 'example.com', scheme: 'https')
client.set_basic_auth(username: 'api', password: 'apipassword')

# Update settins - site title and description
client.update_settings(title: 'My First Site', description: 'Site description')
```

## Users

```ruby
# Get user profile
user = client.users(search: 'wp_login', should_raise_on_empty: false)&.first
client.update_user(user.id, name: 'Testov Test') if user.present?
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/distroid/wp-api.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

