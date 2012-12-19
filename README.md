# WebSocket Server for Ruby

WebSocket-EventMachine-Server is Ruby WebSocket server based on EventMachine.

## Why another WebSocket server?

There are multiple Ruby WebSocket servers, each with different quirks and errors. Most commonly used em-websocket is unfortunately slow and have multiple bugs(see Autobahn tests below). This library was created to fix most of them.

[Autobahn tests](http://imanel.github.com/websocket-ruby/autobahn/server/)

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
EventMachine.run {

    WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen {
          puts "WebSocket connection open"

          # publish message to the client
          ws.send "Hello Client"
        }

        ws.onclose { puts "Connection closed" }
        ws.onmessage { |msg|
          puts "Recieved message: #{msg}"
          ws.send "Pong: #{msg}"
        }
    end
}
```

## Secure server

It is possible to accept secure wss:// connections by passing :secure => true when opening the connection. Safari 5 does not currently support prompting on untrusted SSL certificates therefore using signed certificates is highly recommended. Pass a :tls_options hash containing keys as described in http://eventmachine.rubyforge.org/EventMachine/Connection.html#M000296

For example,

```ruby
WebSocket::EventMachine::Server.start({
    :host => "0.0.0.0",
    :port => 443,
    :secure => true,
    :tls_options => {
      :private_key_file => "/private/key",
      :cert_chain_file => "/ssl/certificate"
    }
}) do |ws|
...
end
```

## Running behind an SSL Proxy/Terminator, like Stunnel

The :secure_proxy => true option makes it possible to run correctly when behind a secure SSL proxy/terminator like [Stunnel](http://www.stunnel.org/). When setting :secure_proxy => true, any reponse from the em-websocket which contains the websocket url will use the wss:// url scheme. None of the traffic is encrypted.

This option is necessary when using websockets with an SSL proxy/terminator on Safari 5.1.x or earlier, and also on Safari in iOS 5.x and earlier. Most versions of Chrome, Safari 5.2, and Safari in iOS 6 do not appear to have this problem.

For example,

```ruby
WebSocket::EventMachine::Server.start({
    :host => "0.0.0.0",
    :port => 8080,
    :secure_proxy => true
}) do |ws|
...
end
```

## Migrating from EM-WebSocket

This library is compatible with EM-WebSocket, so only thing you need to change is running server - you need to change from EM-WebSocket to WebSocket::EventMachine::Server in your application and everything will be working.

## License

The MIT License - Copyright (c) 2012 Bernard Potocki
