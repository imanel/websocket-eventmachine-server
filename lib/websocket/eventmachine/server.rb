require 'websocket-eventmachine-base'

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

      public

      #########################
      ### Inherited methods ###
      #########################

      # Called when connection is opened.
      # No parameters are passed to block
      def onopen(&blk); super; end

      # Called when connection is closed.
      # No parameters are passed to block
      def onclose(&blk); super; end

      # Called when error occurs.
      # One parameter passed to block:
      #   error - string with error message
      def onerror(&blk); super; end

      # Called when message is received.
      # Two parameters passed to block:
      #   message - string with received message
      #   type - type of message. Valid values are :text and :binary
      def onmessage(&blk); super; end

      # Called when ping message is received
      # One parameter passed to block:
      #   message - string with ping message
      def onping(&blk); super; end

      # Called when pond message is received
      # One parameter passed to block:
      #   message - string with pong message
      def onpong(&blk); super; end

      # Send data
      # @param data [String] Data to send
      # @param args [Hash] Arguments for send
      # @option args [String] :type Type of frame to send - available types are "text", "binary", "ping", "pong" and "close"
      # @option args [Integer] :code Code for close frame
      # @return [Boolean] true if data was send, otherwise call on_error if needed
      def send(data, args = {}); super; end

      # Close connection
      # @return [Boolean] true if connection is closed immediately, false if waiting for other side to close connection
      def close(code = 1000, data = nil); super; end

      # Send ping message
      # @return [Boolean] false if protocol version is not supporting ping requests
      def ping(data = ''); super; end

      # Send pong message
      # @return [Boolean] false if protocol version is not supporting pong requests
      def pong(data = ''); super; end

    end
  end
end
