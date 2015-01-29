defmodule Hank.Commands do
  defmacro __using__(_) do
    quote do
      def load_hook(client, hook, function) do
        GenServer.cast(client, {:load_hook, hook, function})
        client
      end

      def remove_hook(client, hook) do
        GenServer.cast(client, {:remove_hook, hook})
        client
      end

      def remove_hook(client, hook, function) do
        GenServer.cast(client, {:remove_hook, hook, function})
        client
      end

      def user(client, nickname, realname) do
       GenServer.cast(client, {:user, nickname, realname})
       client
      end

      def join(client, channel) do
       GenServer.cast(client, {:join, channel})
       client
      end

      def join(client, channel, key) do
       GenServer.cast(client, {:join, channel, key})
       client
      end

      def part(client, channel) do
       GenServer.cast(client, {:part, channel})
       client
      end

      def part(client, channel, message) do
       GenServer.cast(client, {:part, channel, message})
       client
      end

      def nick(client, nickname) do
       GenServer.cast(client, {:nick, nickname})
       client
      end

      def privmsg(client, target, message) do
       GenServer.cast(client, {:privmsg, target, message})
       client
      end

      def ctcp(client, target, message) do
       GenServer.cast(client, {:ctcp, target, message})
       client
      end

      def action(client, target, message) do
       GenServer.cast(client, {:action, target, message})
       client
      end

      def notice(client, target, message) do
       GenServer.cast(client, {:notice, target, message})
       client
      end

      def quit(client) do
       GenServer.cast(client, :quit)
       client
      end

      def quit(client, message) do
       GenServer.cast(client, {:quit, message})
       client
      end

      def kick(client, channel, target) do
       GenServer.cast(client, {:kick, channel, target})
       client
      end

      def kick(client, channel, target, message) do
       GenServer.cast(client, {:kick, channel, target, message})
       client
      end

      def mode(client, target, flags) do
       GenServer.cast(client, {:mode, target, flags})
       client
      end

      def mode(client, target, flags, args) do
       GenServer.cast(client, {:mode, target, flags, args})
       client
      end

      def invite(client, target, channel) do
       GenServer.cast(client, {:invite, target, channel})
       client
      end

      def pong(client, args) do
       GenServer.cast(client, {:pong, args})
       client
      end

      def whois(client, target) do
       GenServer.cast(client, {:whois, target})
       client
      end

      def raw(client, message) do
       GenServer.cast(client, {:raw, message})
       client
      end
    end
  end
end
