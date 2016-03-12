# pusher-fake [![Build Status](http://img.shields.io/travis/tristandunn/pusher-fake.svg)](https://travis-ci.org/tristandunn/pusher-fake) [![Dependency Status](http://img.shields.io/gemnasium/tristandunn/pusher-fake.svg)](https://gemnasium.com/tristandunn/pusher-fake) [![Code Climate](http://img.shields.io/codeclimate/github/tristandunn/pusher-fake.svg)](https://codeclimate.com/github/tristandunn/pusher-fake) [![Coverage Status](http://img.shields.io/coveralls/tristandunn/pusher-fake.svg)](https://coveralls.io/r/tristandunn/pusher-fake?branch=master)

A fake [Pusher](https://pusher.com) server for development and testing.

When run, an entire fake service is started on two random open ports. Connections can then be made to the service without needing a Pusher account. The host and port for the socket and web servers can be found by checking the configuration.

The project is intended to fully replace the Pusher service with a local version for testing and development purposes. It is not intended to be a replacement for production usage!

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
# Ensure it's only run in a development environment if it's a global file.
if Rails.env.development?
  # Ensure Pusher configuration is set if you're not doing so elsewhere.
  Pusher.app_id = "MY_TEST_ID"
  Pusher.key    = "MY_TEST_KEY"
  Pusher.secret = "MY_TEST_SECRET"

  # Require the base file, which immediately starts the socket and web servers.
  #
  # If you're including this file in multiple processes, you may want to add an
  # additional check or even possibly hard code the socket and web ports.
  require "pusher-fake/support/base"
end
```

If you're using Foreman, or something similar, you'll only want to run the fake for a single process:

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

### SSL

The WebSocket server is provided all `socket_options`, allowing you to set the `secure` and `tls_options` options to [create a secure server](https://github.com/igrigorik/em-websocket#secure-server).

The web server passes all `web_options`, besides `host` and `port`, to the Thin backend via attribute writers, allowing you to set the `ssl` and `ssl_options` options.

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
