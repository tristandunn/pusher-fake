# pusher-fake [![Build Status](http://img.shields.io/travis/tristandunn/pusher-fake.svg)](https://travis-ci.org/tristandunn/pusher-fake) [![Dependency Status](http://img.shields.io/gemnasium/tristandunn/pusher-fake.svg)](https://gemnasium.com/tristandunn/pusher-fake) [![Code Climate](http://img.shields.io/codeclimate/github/tristandunn/pusher-fake.svg)](https://codeclimate.com/github/tristandunn/pusher-fake) [![Coverage Status](http://img.shields.io/coveralls/tristandunn/pusher-fake.svg)](https://coveralls.io/r/tristandunn/pusher-fake?branch=master)

A fake [Pusher](http://pusher.com) server for development and testing.

It's intended to fully replace the Pusher service with a local version for testing, but can also be used for development purposes. It is not intended to be a replacement for production usage.

## Usage

### Test Environment

#### 1. Use the PusherFake JS for the Pusher JS instance.

```erb
<script>
  <% if defined?(PusherFake) %>
    // Test environment.
    //
    // Note: Ensure output is not HTML escaped, such as with the raw helper in Rails.
    var instance = <%= PusherFake.javascript %>;
  <% else %>
    // Other environments, such as production.
    var instance = new Pusher(...);
  <% end %>
</script>
```

#### 2. Start PusherFake in your environment.

##### RSpec

```ruby
require "pusher-fake/support/rspec"
```

##### Cucumber

```ruby
require "pusher-fake/support/cucumber"
```

##### Other

```ruby
require "pusher-fake/support/base"

# Reset the channels after each test:
PusherFake::Channel.reset
```

### Development Environment

In a Rails initializer, or any file executed during loading:

```ruby
require "pusher-fake/support/base"
```

If you're using Foreman or something similar you'll only want to run the fake for a single process:

```ruby
if ENV["PUSHER_FAKE"]
  require "pusher-fake/support/base"
end
```

```
web: PUSHER_FAKE=1 bundle exec unicorn ...
worker: bundle exec ...
```

### Clients

If you're creating a `Pusher::Client` instance and wish to use the fake, you need to provide the options.

```ruby
Pusher::Client.new({
  key:    Pusher.key,
  app_id: Pusher.app_id,
  secret: Pusher.secret
}.merge(PusherFake.configuration.web_options))
```

## Configuration

Note that the application ID, API key, and token are automatically set to the `Pusher` values when using an included support file.

### Settings

Setting   | Description
----------|------------
app_id | The Pusher application ID.
key | The Pusher API key.
logger | An IO instance for verbose logging.
secret | The Pusher API token.
socket_options | Socket server options. See `EventMachine::WebSocket.start` for options.
verbose | Enable verbose logging.
web_options | Web server options. See `Thin::Server` for options.
webhooks | Array of webhook URLs.

### Usage

```ruby
# Single setting.
PusherFake.configuration.verbose = true

# Multiple settings.
PusherFake.configure do |configuration|
  configuration.logger  = Rails.logger
  configuration.verbose = true
end
```

## Examples

* [pusher-fake-example](https://github.com/tristandunn/pusher-fake-example) - An example of using pusher-fake with RSpec to test a Rails application.

## Goal

Fully recreate the Pusher API service for development and testing.

#### Why?

* Using a remote API for testing is slow.
* Working offline is currently impossible.
* Wasting connections and messages in development is unreasonable.
* Stubbing the JavaScript, such as with [pusher-test-stub](https://github.com/leggetter/pusher-test-stub), is suboptimal and tedious for integration tests.

## License

pusher-fake uses the MIT license. See LICENSE for more details.
