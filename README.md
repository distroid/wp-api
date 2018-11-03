# WP::API -> v.2

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

# use proxies
client = WP::API::Client.new(host: 'example.com', scheme: 'https')
client.set_proxy('1.2.3.4', 80, 'proxyusername', 'proxypassword') # username & password are optional
client.post_meta(1234) # => metadata for post #1234

```
