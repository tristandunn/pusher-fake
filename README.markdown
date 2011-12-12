# pusher-fake

A fake [Pusher](http://pusher.com) server for development and testing.

## Goal

Fully recreate the Pusher API service for development and testing.

#### Why?

* Using a remote API for testing is slow.
* Working offline is currently impossible.
* Wasting connections and messages in development is unreasonable.
* Stubbing the JavaScript, such as with [pusher-test-stub](https://github.com/leggetter/pusher-test-stub), is suboptimal and tedious for integration tests.

## Supported

* Connecting.
* Subscribing to public and private channels.
* Triggering events and client events on channels.
* Unsubscribing from channels.

## License

pusher-fake uses the MIT license. See LICENSE for more details.
