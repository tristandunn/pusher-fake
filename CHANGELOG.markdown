# Changelog

## 1.6.0 — Unreleased

* Update development and test dependencies. (Tristan Dunn)

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

## 0.13.0 — January 15, 2014

* Remove deprecated configuration options. (Tristan Dunn)
* Update the Pusher JS client to version 2.1.6. (Tristan Dunn)
* Miscellaneous clean up. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.12.0 — December 21, 2013

* Update the Pusher JS client to version 2.1.5. (Tristan Dunn)
* Update dependencies. (Tristan Dunn, Matthieu Aussaguel)

## 0.11.0 — October 30, 2013

* Support setting custom options on the socket and web server. (Tristan Dunn)
* Update the Pusher JS client to version 2.1.3. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.10.0 — August 26, 2013

* Resolve dependency issue. (Tristan Dunn)
* Update the Pusher JS client to version 2.1.2. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.9.0 — June 6, 2013

* Use fuzzy version requirement for runtime dependencies. (Patrick Van Stee)
* Update dependencies. (Tristan Dunn)

## 0.8.0 — May 11, 2013

* Update dependencies. (Tristan Dunn)

## 0.7.0 — February 25, 2013

* Raise and log on unknown server paths. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.6.0 — January 23, 2013

* Add a file for easily starting the fake server in Cucumber. (Tristan Dunn)
* Add convenience method for the JS to override Pusher client configuration. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.5.0 — January 21, 2013

* Support channel, channels, and user REST API endpoints. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.4.0 — December 14, 2012

* Support excluding recipients. (Tristan Dunn)
* Don't deliver client events to the originator of the event. (Thomas Walpole)
* Update dependencies. (Tristan Dunn)

## 0.3.0 — December 12, 2012

* Support triggering webhooks. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.2.0 — November 28, 2012

* Replace ruby-hmac with openssl. (Sergey Nartimov)
* Use multi_json instead of yajl-ruby. (Sergey Nartimov)
* Update dependencies. (Tristan Dunn)

## 0.1.5 — November 12, 2012

* Use the new Pusher event format. (Tristan Dunn)
* Upgraded the Pusher JS client to version 1.12.5. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.1.4 — July 15, 2012

* Upgraded the Pusher JS client to version 1.12.1. (Tristan Dunn)
* Improve documentation. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.1.3 — July 9, 2012

* Ensure the server returns a valid JSON response. (Marko Anastasov)
* Handle channels not being defined when attempting to remove a connection. (Tristan Dunn)
* Update dependencies. (Tristan Dunn)

## 0.1.2 — April 19, 2012

* Make subscription_data match Pusher v1.11 format. (Thomas Walpole)
* Miscellaneous clean up. (Tristan Dunn)

## 0.1.1 — March 29, 2012

* Added support for parametric app_id in configuration and application server. (Alessandro Morandi)
* Upgraded the Pusher JS client to version 1.11.2. (Tristan Dunn)
* Added Rake as a development dependency. (Tristan Dunn)
* Miscellaneous clean up. (Tristan Dunn)

## 0.1.0 — March 14, 2012

* Initial release.
