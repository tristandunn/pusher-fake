module PusherFake
  module Extensions
    module ParentTrap
      # EventMachine and Thin both trap INT when they start their servers. Patch
      # them to call any previous handler.
      def trap(*args, &block)
        parent_trap = super(*args) {
          yield
          parent_trap&.call
        }
      end
    end
  end
end

EventMachine::WebSocket.singleton_class.prepend PusherFake::Extensions::ParentTrap
Thin::Server.prepend PusherFake::Extensions::ParentTrap
