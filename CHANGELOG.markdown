# Changelog

## Unreleased

* Add support for Ruby 3.1. (Tristan Dunn)
* Drop support for Ruby 2.6. (Tristan Dunn)
* Update the Pusher JS client to version 7.0.6. (Tristan Dunn)
* Require MFA for privileged operations on RubyGems. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)
* Replace coveralls with simplecov. (Tristan Dunn)

## 3.0.1 — September 10th, 2021

* Handle `StringIO` being assigned to `$stdout`. (Tristan Dunn)
* Update development dependencies. (Tristan Dunn)

## 3.0.0 — August 10th, 2021

* Add support for Ruby 3.0. (Tristan Dunn)
* Drop support for Ruby 2.4 and 2.5. (Tristan Dunn)
* Update development dependencies. (Tristan Dunn)

## 2.2.0 — September 16th, 2020

* Enable support for Windows by using a thread instead of fork. (Ian Clarkson)
* Update development dependencies. (Tristan Dunn)

## 2.1.0 — September 5th, 2020

* Remove deprecated Cucumber file. (Tristan Dunn)
* Update the Pusher JS client to version 7.0.0. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)

## 2.0.0 — March 31st, 2020

* Add support for Ruby 2.7. (Tristan Dunn)
* Fix connection ID for Ruby 2.7. (Mark Thorn)
* Drop support for Ruby 2.2 and 2.3. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)

## 1.12.0 — April 2nd, 2019

* Add webhooks options to binary. (nytai)
* Update development and test dependencies. (Tristan Dunn)

## 1.11.0 — November 17th, 2018

* Add statistics configuration and disable by default. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)

## 1.10.0 — September 5th, 2018

* Ensure the application ID is a string. (Craig McNamara)
* Fix a typo in the README. (Jouke Waleson)
* Update development and test dependencies. (Tristan Dunn)

## 1.9.0 — November 1st, 2017

* Warn when the library is not required before a support file. (Tristan Dunn)
* Update the Pusher JS client to version 4.2.1. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)

## 1.8.0 — March 13th, 2017

* Add a `pusher-fake` binary to run the servers. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)

## 1.7.0 — November 4th, 2016

* Add support for batch events. (Tyler Hogan)
* Update the Pusher JS client to version 3.2.1. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)

## 1.6.0 — July 31st, 2016

* Update development and test dependencies. (Tristan Dunn)
* Update the Pusher JS client to version 3.1.0. (Tristan Dunn)

## 1.5.0 — February 12th, 2016

* Warn when Pusher configuration is not set. (Tristan Dunn)
* Update the Pusher JS client to version 3.0.0. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)

## 1.4.0 — May 20th, 2015

* Update development and test dependencies. (Tristan Dunn)

## 1.3.0 — February 16th, 2015

* Only enable the WebSocket transport. (Tristan Dunn)
* Update the Pusher JS client to version 2.2.4. (Tristan Dunn)
* Update development and test dependencies. (Tristan Dunn)

## 1.2.0 — August 9th, 2014

* Default socket and web ports to available ports. (Tristan Dunn)
* Update development dependencies. (Tristan Dunn)

## 1.1.0 — July 22nd, 2014

* Add support for frameworks besides Cucumber. (Tristan Dunn)
* Update development dependencies. (Tristan Dunn)

## 1.0.1 — June 9th, 2014

* Update the Pusher JS client to version 2.2.2. (Tristan Dunn)

## 1.0.0 — June 7th, 2014

* Double encode JSON data to match Pusher. (Tristan Dunn, Adrien Jarthon)
* Treat socket_id as a string to match Pusher. (Tristan Dunn, Adrien Jarthon)
* Trigger client_event webhooks. (Tristan Dunn).
* Add verbose logging. (Tristan Dunn)
* Miscellaneous clean up. (Tristan Dunn)
* Update the Pusher JS client to version 2.2.1. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.14.0 — February 19th, 2014

* Handle pusher:ping events from client. (Mark Thorn)
* Avoid issue when removing unsubscribed connection from presence channel. (Mark Thorn)
* Add initial support for verbose logging. (Tristan Dunn)
* Change coveralls to be a test dependency. (Tristan Dunn)
* Miscellaneous clean up. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.13.0 — January 15th, 2014

* Remove deprecated configuration options. (Tristan Dunn)
* Update the Pusher JS client to version 2.1.6. (Tristan Dunn)
* Miscellaneous clean up. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.12.0 — December 21st, 2013

* Update the Pusher JS client to version 2.1.5. (Tristan Dunn)
* Update dependencies. (Tristan Dunn, Matthieu Aussaguel)

## 0.11.0 — October 30th, 2013

* Support setting custom options on the socket and web server. (Tristan Dunn)
* Update the Pusher JS client to version 2.1.3. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.10.0 — August 26th, 2013

* Resolve dependency issue. (Tristan Dunn)
* Update the Pusher JS client to version 2.1.2. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.9.0 — June 6th, 2013

* Use fuzzy version requirement for runtime dependencies. (Patrick Van Stee)
* Update dependencies. (Tristan Dunn)

## 0.8.0 — May 11th, 2013

* Update dependencies. (Tristan Dunn)

## 0.7.0 — February 25th, 2013

* Raise and log on unknown server paths. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.6.0 — January 23rd, 2013

* Add a file for easily starting the fake server in Cucumber. (Tristan Dunn)
* Add convenience method for the JS to override Pusher client configuration. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.5.0 — January 21st, 2013

* Support channel, channels, and user REST API endpoints. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.4.0 — December 14th, 2012

* Support excluding recipients. (Tristan Dunn)
* Don't deliver client events to the originator of the event. (Thomas Walpole)
* Update dependencies. (Tristan Dunn)

## 0.3.0 — December 12th, 2012

* Support triggering webhooks. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.2.0 — November 28th, 2012

* Replace ruby-hmac with openssl. (Sergey Nartimov)
* Use multi_json instead of yajl-ruby. (Sergey Nartimov)
* Update dependencies. (Tristan Dunn)

## 0.1.5 — November 12th, 2012

* Use the new Pusher event format. (Tristan Dunn)
* Upgraded the Pusher JS client to version 1.12.5. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.1.4 — July 15th, 2012

* Upgraded the Pusher JS client to version 1.12.1. (Tristan Dunn)
* Improve documentation. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.1.3 — July 9th, 2012

* Ensure the server returns a valid JSON response. (Marko Anastasov)
* Handle channels not being defined when attempting to remove a connection. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.1.2 — April 19th, 2012

* Make subscription_data match Pusher v1.11 format. (Thomas Walpole)
* Miscellaneous clean up. (Tristan Dunn)

## 0.1.1 — March 29th, 2012

* Added support for parametric app_id in configuration and application server. (Alessandro Morandi)
* Upgraded the Pusher JS client to version 1.11.2. (Tristan Dunn)
* Added Rake as a development dependency. (Tristan Dunn)
* Miscellaneous clean up. (Tristan Dunn)

## 0.1.0 — March 14th, 2012

* Initial release.
