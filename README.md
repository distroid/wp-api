# WP::API -> v.2

[![Circle CI](https://circleci.com/gh/colinyoung/wp-api.png?style=badge)](https://circleci.com/gh/colinyoung/wp-api)

It is update original gem for compatibility with [WP REST API v2.0 (WP-API)](http://v2.wp-api.org/)

## Installation

    gem 'wp-api', git: "https://github.com/omalab/wp-api"
    bundle

## Authentication



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Usage

This gem can use the Basic Auth plugin, which will let you use a username/password to authenticate.
This plugin is available here: https://github.com/WP-API/Basic-Auth

This also needs exposed the custom post types on the REST API. This can be done with the REST API Controller plugin.

```
client = WP::API['yourwpsite.com']

# List all posts
client.posts

# List all users
client.users

# List alternate post types
client.posts(type: 'custom_posts')

# Append paramters
client.posts(posts_per_page: 1000)

# Use basic auth (used to access post meta)
client = WP::API::Client.new(host: 'yourwpsite.com', scheme: 'https', user: 'api', password: 'apipassword')
client.post_meta(1234) # => metadata for post #1234

```
