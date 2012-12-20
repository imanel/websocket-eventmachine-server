# WebSocket Server for Ruby

WebSocket-EventMachine-Server is Ruby WebSocket server based on EventMachine.

## Why another WebSocket server?

There are multiple Ruby WebSocket servers, each with different quirks and errors. Most commonly used em-websocket is unfortunately slow and have multiple bugs(see Autobahn tests below). This library was created to fix most of them.

[Autobahn tests](http://imanel.github.com/websocket-ruby/autobahn/server)

## Installation

``` bash
gem install websocket-eventmachine-server
```

or in Gemfile

``` ruby
gem 'websocket-eventmachine-server'
```

## Simple server example

```ruby
EM.run do

  WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do
      puts "Client connected"
    end

    ws.onmessage do |msg, type|
      puts "Received message: #{msg}"
      ws.send msg, :type => type
    end

    ws.onclose do
      puts "Client disconnected"
    end
  end

end
```

## Options

Following options can be passed to WebSocket::EventMachine::Server initializer:

`:host` - `[String]` IP on which server should accept connections. '0.0.0.0' means all.
`:port` - `[Integer]` Port on which server should accept connections.
`:secure` - `[Boolean]` Enable secure WSS protocol. This will enable both SSL encryption and using WSS url and require `tls_options` key.
`:secure_proxy` - `[Boolean]` Enable secure WSS protocol over proxy. This will enable only using WSS url and assume that SSL encryption is handled by some kind proxy(like [Stunnel](http://www.stunnel.org/))
`:tls_options` - `[Hash]` Options for SSL(according to [EventMachine start_tls method](http://eventmachine.rubyforge.org/EventMachine/Connection.html#start_tls-instance_method))
  `:private_key_file` - `[String]` URL to private key file
  `:cert_chain_file` - `[String]` URL to cert chain file

## Methods

Following methods are available for WebSocket::EventMachine::Server object:

### onopen

Called after client is connected.

Example:

```ruby
ws.onopen do
  puts "Client connected"
end
```

### onclose

Called after client closed connection.

Example:

```ruby
ws.onclose do
  puts "Client disconnected"
end
```

### onmessage

Called when server receive message. Two parameters are passed:

- `[String]` message - content of message
- `[Symbol]` type - type is type of message(:text or :binary)

Example:

```ruby
ws.onmessage do |msg, type|
  puts "Received message: #{msg} or type: #{type}"
end
```

### onerror

Called when server discovers error. One parameter is passed:

- `[String]` error - error reason.

Example:

```ruby
ws.onerror do |error|
  puts "Error occured: #{error}"
end
```

### onping

Called when server receive ping request. Pong request is sent automatically. One parameter is passed:

- `[String]` message - message for ping request.

Example:

```ruby
ws.onping do |message|
  puts "Ping received: #{message}"
end
```

### onpong

Called when server receive pong response. One parameter is passed:

- `[String]` message - message for pong response.

Example:

```ruby
ws.onpong do |message|
  puts "Pong received: #{message}"
end
```

### send

Sends message to client. Params:

- `[String]` message - message that should be sent to client
- `[Hash]` params - params for message(optional)
  - `[Symbol]` type - type of message. Valid values are :text, :binary(default is :text)

Example:

```ruby
ws.send "Hello Client!"
ws.send "binary data", :type => :binary
```

### close

Closes connection and optionally send close frame to client. Params:

- `[Integer]` code - code of closing, according to WebSocket specification(optional)
- `[String]` data - data to send in closing frame(optional)

Example:

```ruby
ws.close
```

### ping

Sends ping request. Params:

- `[String]` data - data to send in ping request(optional)

Example:

```ruby
ws.ping 'Hi'
```

### pong

Sends pong request. Usually there should be no need to send this request, as pong responses are sent automatically by server. Params:

- `[String]` data - data to send in pong request(optional)

Example:

``` ruby
ws.pong 'Hello'
```

## Migrating from EM-WebSocket

This library is compatible with EM-WebSocket, so only thing you need to change is running server - you need to change from EM-WebSocket to WebSocket::EventMachine::Server in your application and everything will be working.

## License

The MIT License - Copyright (c) 2012 Bernard Potocki
