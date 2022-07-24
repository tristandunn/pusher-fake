# frozen_string_literal: true

# :nocov:
module PusherFake
  module Server
    # Monkeypatch to ensure previous trap handlers are called when new handlers
    # are added.
    #
    # @see +PusherFake::Server.chain_trap_handlers+
    module ChainTrapHandlers
      # Ensure a previous trap is chained when a new trap is added.
      #
      # @see +Signal.trap+
      def trap(*arguments)
        previous_trap = super do
          yield

          previous_trap&.call
        end
      end
    end
  end
end
# :nocov:
