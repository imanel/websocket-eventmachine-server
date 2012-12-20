require 'websocket-eventmachine-base'
require 'eventmachine'

module WebSocket
  module EventMachine

    # WebSocket Server (using EventMachine)
    # @example
    #   WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => 8080) do |ws|
    #     ws.onopen    { ws.send "Hello Client!"}
    #     ws.onmessage { |msg| ws.send "Pong: #{msg}" }
    #     ws.onclose   { puts "WebSocket closed" }
    #     ws.onerror   { |e| puts "Error: #{e}" }
    #   end
    class Server < Base

      ###########
      ### API ###
      ###########

      # Start server
      # @param options [Hash] The request arguments
      # @option args [String] :host The host IP/DNS name
      # @option args [Integer] :port The port to connect too(default = 80)
      def self.start(options, &block)
        ::EventMachine::start_server(options[:host], options[:port], self, options) do |c|
          block.call(c)
        end
      end

      # Initialize connection
      # @param args [Hash] Arguments for server
      # @option args [Boolean] :debug Should server log debug data?
      # @option args [Boolean] :secure If true then server will run over SSL
      # @option args [Boolean] :secure_proxy If true then server will use wss protocol but will not encrypt connection. Usefull for sll proxies.
      # @option args [Hash] :tls_options Options for SSL if secure = true
      def initialize(args)
        @debug = !!args[:debug]
        @secure = !!args[:secure]
        @secure_proxy = args[:secure_proxy] || @secure
        @tls_options = args[:tls_options] || {}
      end

      ############################
      ### EventMachine methods ###
      ############################

      # Eventmachine internal
      # @private
      def post_init
        @state = :connecting
        @handshake = WebSocket::Handshake::Server.new(:secure => @secure_proxy)
        start_tls(@tls_options) if @secure
      end

      #######################
      ### Private methods ###
      #######################

      private

      def incoming_frame
        WebSocket::Frame::Incoming::Server
      end

      def outgoing_frame
        WebSocket::Frame::Outgoing::Server
      end

    end
  end
end
