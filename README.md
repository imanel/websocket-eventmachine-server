# WebSocket Server for Ruby

WebSocket-EventMachine-Server is Ruby WebSocket server based on EventMachine.

- [Autobahn tests](http://imanel.github.com/websocket-ruby/autobahn/server)
- [Docs](http://rdoc.info/github/imanel/websocket-eventmachine-server/master/frames)

## Why another WebSocket server?

There are multiple Ruby WebSocket servers, each with different quirks and errors. Most commonly used em-websocket is unfortunately slow and have multiple bugs(see Autobahn tests above). This library was created to fix most of them.

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

- `[String] :host` - IP on which server should accept connections. '0.0.0.0' means all.
- `[Integer] :port` - Port on which server should accept connections.
- `[Boolean] :secure` - Enable secure WSS protocol. This will enable both SSL encryption and using WSS url and require `tls_options` key.
- `[Boolean] :secure_proxy` - Enable secure WSS protocol over proxy. This will enable only using WSS url and assume that SSL encryption is handled by some kind proxy(like [Stunnel](http://www.stunnel.org/))
- `[Hash] :tls_options` - Options for SSL(according to [EventMachine start_tls method](http://eventmachine.rubyforge.org/EventMachine/Connection.html#start_tls-instance_method))
  - `[String] :private_key_file` - URL to private key file
  - `[String] :cert_chain_file` - URL to cert chain file

## Methods

Following methods are available for WebSocket::EventMachine::Server object:

### onopen

Called after client is connected.

Parameters:

- `[Handshake] handshake` - full handshake. See [specification](http://www.rubydoc.info/github/imanel/websocket-ruby/WebSocket/Handshake/Base) for available methods.

Example:

```ruby
ws.onopen do |handshake|
  puts "Client connected with params #{handshake.query}"
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

Called when server receive message.

Parameters:

- `[String] message` - content of message
- `[Symbol] type` - type is type of message(:text or :binary)

Example:

```ruby
ws.onmessage do |msg, type|
  puts "Received message: #{msg} or type: #{type}"
end
```

### onerror

Called when server discovers error.

Parameters:

- `[String] error` - error reason.

Example:

```ruby
ws.onerror do |error|
  puts "Error occured: #{error}"
end
```

### onping

Called when server receive ping request. Pong request is sent automatically.

Parameters:

- `[String] message` - message for ping request.

Example:

```ruby
ws.onping do |message|
  puts "Ping received: #{message}"
end
```

### onpong

Called when server receive pong response.

Parameters:

- `[String] message` - message for pong response.

Example:

```ruby
ws.onpong do |message|
  puts "Pong received: #{message}"
end
```

### send

Sends message to client.

Parameters:

- `[String] message` - message that should be sent to client
- `[Hash] params` - params for message(optional)
  - `[Symbol] :type` - type of message. Valid values are :text, :binary(default is :text)

Example:

```ruby
ws.send "Hello Client!"
ws.send "binary data", :type => :binary
```

### close

Closes connection and optionally send close frame to client.

Parameters:

- `[Integer] code` - code of closing, according to WebSocket specification(optional)
- `[String] data` - data to send in closing frame(optional)

Example:

```ruby
ws.close
```

### ping

Sends ping request.

Parameters:

- `[String] data` - data to send in ping request(optional)

Example:

```ruby
ws.ping 'Hi'
```

### pong

Sends pong request. Usually there should be no need to send this request, as pong responses are sent automatically by server.

Parameters:

- `[String] data` - data to send in pong request(optional)

Example:

``` ruby
ws.pong 'Hello'
```

## Migrating from EM-WebSocket

This library is compatible with EM-WebSocket, so only thing you need to change is running server - you need to change from EM-WebSocket to WebSocket::EventMachine::Server in your application and everything will be working.

## Using self-signed certificate

Read more [here](https://github.com/kanaka/websockify/wiki/Encrypted-Connections).

## Support

If you like my work then consider supporting me:

[![Donate with Bitcoin](https://en.cryptobadges.io/badge/small/bc1qmxfc703ezscvd4qv0dvp7hwy7vc4kl6currs5e)](https://en.cryptobadges.io/donate/bc1qmxfc703ezscvd4qv0dvp7hwy7vc4kl6currs5e)

[![Donate with Ethereum](https://en.cryptobadges.io/badge/small/0xA7048d5F866e2c3206DC95ebFa988fF987c0BccB)](https://en.cryptobadges.io/donate/0xA7048d5F866e2c3206DC95ebFa988fF987c0BccB)

## License

(The MIT License)

Copyright © 2012 Bernard Potocki

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
