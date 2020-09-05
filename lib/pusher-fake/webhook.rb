# frozen_string_literal: true

module PusherFake
  # Webhook triggering.
  class Webhook
    class << self
      def trigger(name, data = {})
        payload = MultiJson.dump(
          events:  [data.merge(name: name)],
          time_ms: Time.now.to_i
        )

        PusherFake.log("HOOK: #{payload}")
        PusherFake.configuration.webhooks.each do |url|
          http = EventMachine::HttpRequest.new(url)
          http.post(body: payload, head: headers_for(payload))
        end
      end

      private

      def headers_for(payload)
        {
          "Content-Type"       => "application/json",
          "X-Pusher-Key"       => PusherFake.configuration.key,
          "X-Pusher-Signature" => signature_for(payload)
        }
      end

      def signature_for(payload)
        digest = OpenSSL::Digest.new("SHA256")
        secret = PusherFake.configuration.secret

        OpenSSL::HMAC.hexdigest(digest, secret, payload)
      end
    end
  end
end
