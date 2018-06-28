# pusher-fake [![Latest Version](https://img.shields.io/gem/v/pusher-fake.svg)](https://rubygems.org/gems/pusher-fake) [![Build Status](https://img.shields.io/travis/tristandunn/pusher-fake/master.svg)](https://travis-ci.org/tristandunn/pusher-fake) [![Coverage Status](http://img.shields.io/coveralls/tristandunn/pusher-fake.svg)](https://coveralls.io/r/tristandunn/pusher-fake?branch=master) [![Maintainability](https://api.codeclimate.com/v1/badges/110c6ef7a313bf8baac3/maintainability)](https://codeclimate.com/github/tristandunn/pusher-fake/maintainability)

A fake [Pusher](https://pusher.com) server for development and testing.

When run, an entire fake service starts on two random open ports. A Pusher account is not required to make connections to the fake service. If you need to know the host or port, you can find the values in the configuration.

The project fully replaces the Pusher service with a local version for testing and development. While mostly functional and clients and servers can exchange messages with it via public, private or presence channels, using the service as a replacement for production is not recommended. There is no high availability and no monitoring.

#### Why?

With SaaS Pusher:
1. Working offline is not possible.
1. Using a remote API for testing is slow.
1. Wasting connections and messages in development is unreasonable.
1. Stubbing the JavaScript, such as with [pusher-test-stub](https://github.com/leggetter/pusher-test-stub), is suboptimal and tedious for integration tests.

## Usage

### Test Environment

#### 1a. Use the PusherFake JS for the Pusher JS instance.

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

#### 1b. If not running in Rails, configure [pusher-js](https://github.com/pusher/pusher-js) manually

```javascript
const socket = new Pusher(APP_KEY, {
  wsPort: LOCAL_PORT,  // the port that the service was started on
  httpPort: LOCAL_PORT,  // same
  wsHost: LOCAL_HOST,  // typically 'localhost' or an internal network IP
  httpHost: LOCAL_HOST,  // same
  encrypted: false,  // do not turn this off for production usage!
});
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

##### Zeus

Using Zeus requires a custom plan. See [an example plan](https://github.com/tristandunn/pusher-fake-example/commit/add6dedad3b6da12cdac818d2fff3696a5d44738) for the configuration necessary.

##### Binary

If you need to run the fake as a standalone service, perhaps when using Docker, there is a `pusher-fake` binary available.

```
$ gem install pusher pusher-fake # or run from source through this repo

$ pusher-fake --help
Usage: pusher-fake [options]
    -i, --id ID                      Use ID as the application ID for Pusher
    -k, --key KEY                    Use KEY as the key for Pusher
    -s, --secret SECRET              Use SECRET as the secret token for Pusher
        --socket-host HOST           Use HOST for the web socket server
        --socket-port PORT           Use PORT for the web socket server
    -v, --[no-]verbose               Run verbosely
        --web-host HOST              Use HOST for the web server
        --web-port PORT              Use PORT for the web server
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
# Avoid running outside of development, if it's a global file.
if Rails.env.development?
  # Set the Pusher configuration, if it's not done elsewhere.
  Pusher.app_id = "MY_TEST_ID"
  Pusher.key    = "MY_TEST_KEY"
  Pusher.secret = "MY_TEST_SECRET"

  # Require the base file, which starts the socket and web servers.
  #
  # If you're including this file in different processes, you may want to add
  # another check or even possibly hard code the socket and web ports.
  require "pusher-fake/support/base"
end
```

If you're using Foreman, or something similar, you'll want to limit the fake to a single process:

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

## License

pusher-fake uses the MIT license. See LICENSE for more details.
