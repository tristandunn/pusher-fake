# pusher-fake [![Build Status](https://secure.travis-ci.org/tristandunn/pusher-fake.png?branch=master)](http://travis-ci.org/tristandunn/pusher-fake) [![Dependency Status](https://gemnasium.com/tristandunn/pusher-fake.png)](https://gemnasium.com/tristandunn/pusher-fake) [![Code Climate](https://codeclimate.com/github/tristandunn/pusher-fake.png)](https://codeclimate.com/github/tristandunn/pusher-fake) [![Coverage Status](https://coveralls.io/repos/tristandunn/pusher-fake/badge.png)](https://coveralls.io/r/tristandunn/pusher-fake)

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

#### 2. Start PusherFake in the Cucumber environment.

```ruby
require "pusher-fake/cucumber"
```

Not using Cucumber? See [pusher-fake/cucumber.rb](https://github.com/tristandunn/pusher-fake/blob/master/lib/pusher-fake/cucumber.rb) for starting it manually.

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
