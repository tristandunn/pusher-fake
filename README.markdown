# pusher-fake [![Build Status](http://img.shields.io/travis/tristandunn/pusher-fake.svg)](https://travis-ci.org/tristandunn/pusher-fake) [![Dependency Status](http://img.shields.io/gemnasium/tristandunn/pusher-fake.svg)](https://gemnasium.com/tristandunn/pusher-fake) [![Code Climate](http://img.shields.io/codeclimate/github/tristandunn/pusher-fake.svg)](https://codeclimate.com/github/tristandunn/pusher-fake) [![Coverage Status](http://img.shields.io/coveralls/tristandunn/pusher-fake.svg)](https://coveralls.io/r/tristandunn/pusher-fake?branch=master)

A fake [Pusher](http://pusher.com) server for development and testing.

## Usage

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

## Examples

* [pusher-fake-example](https://github.com/tristandunn/pusher-fake-example) - An example of using pusher-fake with Cucumber to test a Rails application.

## Goal

Fully recreate the Pusher API service for development and testing.

#### Why?

* Using a remote API for testing is slow.
* Working offline is currently impossible.
* Wasting connections and messages in development is unreasonable.
* Stubbing the JavaScript, such as with [pusher-test-stub](https://github.com/leggetter/pusher-test-stub), is suboptimal and tedious for integration tests.

## License

pusher-fake uses the MIT license. See LICENSE for more details.
