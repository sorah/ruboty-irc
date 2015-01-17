require "zircon"

module Ruboty
  module Adapters
    class Irc < Base
      env :IRC_SERVER, "irc server host"
      env :IRC_PORT, "irc server port", optional: true
      env :IRC_USERNAME, "irc username", optional: true
      env :IRC_PASSWORD, "irc password", optional: true
      env :IRC_CHANNEL, "irc channel to join", optional: true

      env :IRC_ENCODING, "irc encoding", optional: true
      env :IRC_DISABLE_ENCODE_BODY, "disable encoding text to UTF-8", optional: true

      def run
        irc.on_privmsg(&method(:on_message))
        irc.run!
      end

      def say(message)
        message[:body].each_line do |msg|
          irc.notice(message[:from], ": #{msg}")
        end 
      end

      def on_message(message)
        if do_auto_encode?
          body = message.body.dup.force_encoding(encoding)
        else
          body = message.body.encode('utf-8', encoding)
        end

        robot.receive(
          type: message.type,
          body: body,
          from: message.from,
          to:   message.to,
        )
      end

      private

      def irc
        @irc ||= Zircon.new(
          server: server,
          port: port,
          channel: channel,
          username: username,
          password: password,
        )
      end

      def server
        ENV['IRC_SERVER']
      end

      def port
        ENV['IRC_PORT'] || 6667
      end

      def username
        ENV['IRC_USERNAME'] || 'ruboty'
      end

      def password
        ENV['IRC_PASSWORD']
      end

      def channel
        ENV['IRC_CHANNEL']
      end

      def encoding
        ENV['IRC_ENCODING'] || 'utf-8'
      end

      def do_auto_encode?
        ENV['IRC_DISABLE_ENCODE_BODY'] != '1'
      end
    end
  end
end
