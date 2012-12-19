require 'websocket'
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
    class Server < ::EventMachine::Connection

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
      # @option args [Hash] :tls_options Options for SSL if secure = true
      def initialize(args)
        @debug = !!args[:debug]
        @secure = args[:secure] || false
        @tls_options = args[:tls_options] || {}
      end

      # Called when connection is opened.
      # No parameters are passed to block
      def onopen(&blk);     @onopen = blk;    end

      # Called when connection is closed.
      # No parameters are passed to block
      def onclose(&blk);    @onclose = blk;   end

      # Called when error occurs.
      # One parameter passed to block:
      #   error - string with error message
      def onerror(&blk);    @onerror = blk;   end

      # Called when message is received from server.
      # Two parameters passed to block:
      #   message - string with message sent to server
      #   type - type of message. Valid values are :text and :binary
      def onmessage(&blk);  @onmessage = blk; end

      # Called when ping message is received from server.
      # One parameter passed to block:
      #   message - string with ping message
      def onping(&blk);     @onping = blk;    end

      # Called when pond message is received from server.
      # One parameter passed to block:
      #   message - string with pong message
      def onpong(&blk);     @onpong = blk;    end

      # Send data to client
      # @param data [String] Data to send
      # @param args [Hash] Arguments for send
      # @option args [String] :type Type of frame to send - available types are "text", "binary", "ping", "pong" and "close"
      # @return [Boolean] true if data was send, otherwise call on_error if needed
      def send(data, args = {})
        type = args[:type] || :text
        unless type == :plain
          frame = WebSocket::Frame::Outgoing::Server.new(:version => @handshake.version, :data => data, :type => type)
          if !frame.supported?
            trigger_onerror("Frame type '#{type}' is not supported in protocol version #{@handshake.version}")
            return false
          elsif !frame.require_sending?
            return false
          end
          data = frame.to_s
        end
        debug "Sending raw: ", data
        send_data(data)
        true
      end

      # Close connection
      # @return [Boolean] true if connection is closed immediately, false if waiting for server to close connection
      def close
        if @state == :open
          @state = :closing
          return false if send('', :type => :close)
        else
          send('', :type => :close) if @state == :closing
          @state = :closed
        end
        close_connection_after_writing
        true
      end

      # Send ping message to client
      # @return [Boolean] false if protocol version is not supporting ping requests
      def ping(data = '')
        send(data, :type => :ping)
      end

      # Send pong message to client
      # @return [Boolean] false if protocol version is not supporting pong requests
      def pong(data = '')
        send(data, :type => :pong)
      end

      ############################
      ### EventMachine methods ###
      ############################

      # @private
      def post_init
        @state = :connecting
        @handshake = WebSocket::Handshake::Server.new(:secure => @secure)
        start_tls(@tls_options) if @secure
      end

      # @private
      def receive_data(data)
        debug "Received raw: ", data
        case @state
        when :connecting then handle_connecting(data)
        when :open then handle_open(data)
        when :closing then handle_closing(data)
        end
      end

      # @private
      def unbind
        unless @state == :closed
          @state = :closed
          close
          trigger_onclose('')
        end
      end

      #######################
      ### Private methods ###
      #######################

      private

      ['onopen'].each do |m|
        define_method "trigger_#{m}" do
          callback = instance_variable_get("@#{m}")
          callback.call if callback
        end
      end

      ['onerror', 'onping', 'onpong', 'onclose'].each do |m|
        define_method "trigger_#{m}" do |data|
          callback = instance_variable_get("@#{m}")
          callback.call(data) if callback
        end
      end

      def trigger_onmessage(data, type)
        @onmessage.call(data, type) if @onmessage
      end

      def handle_connecting(data)
        @handshake << data
        return unless @handshake.finished?
        if @handshake.valid?
          send(@handshake.to_s, :type => :plain) if @handshake.should_respond?
          @frame = WebSocket::Frame::Incoming::Server.new(:version => @handshake.version)
          @state = :open
          trigger_onopen
          handle_open(@handshake.leftovers) if @handshake.leftovers
        else
          trigger_onerror(@handshake.error)
          close
        end
      end

      def handle_open(data)
        @frame << data
        while frame = @frame.next
          case frame.type
          when :close
            @state = :closing
            close
            trigger_onclose(frame.to_s)
          when :ping
            pong(frame.to_s)
            trigger_onping(frame.to_s)
          when :pong
            trigger_onpong(frame.to_s)
          when :text
            trigger_onmessage(frame.to_s, :text)
          when :binary
            trigger_onmessage(frame.to_s, :binary)
          end
        end
        unbind if @frame.error?
      end

      def handle_closing(data)
        @state = :closed
        close
        trigger_onclose
      end

      def debug(description, data)
        return unless @debug
        puts(description + data.bytes.to_a.collect{|b| '\x' + b.to_s(16).rjust(2, '0')}.join) unless @state == :connecting
      end

    end
  end
end
