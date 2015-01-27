defmodule Hank.Client do
  use GenServer
  alias Hank.Message
  alias Hank.Connection
  alias Hank.Client.State, as: Client

  defmodule State do
    defstruct [
      connection:  nil,
      channels:    [],
      nickname:    nil,
      realname:    nil,
      hooks:       [],
      extra:       [],
    ]
  end

  def start_link(%Client{} = client) do
    GenServer.start_link(__MODULE__, client)
  end

  @doc """
  Register the client with the irc server and add the connections PID to the
  client state
  """
  def handle_cast({:handshake, connection}, %Client{nickname: nick, realname: name} = client) do
    client = %Client{client | connection: connection}
    Connection.send_message("NICK #{nick}", connection)
    Connection.send_message("USER #{nick} 0 * :#{name}", connection)
    {:noreply, client}
  end

  def handle_cast({:load_hook, hook, function}, %Client{hooks: hooks} = client) do
    {:noreply, %Client{client | hooks: [{hook, function} | hooks]}}
  end

  def handle_cast({:remove_hook, hook}, %Client{hooks: hooks} = client) do
    {:noreply, %Client{client | hooks: hooks -- hook}}
  end

  def handle_cast(%Message{command: hook} = message, %Client{hooks: hooks} = client) do
    if Keyword.has_key?(hooks, hook) do
      for function <- Keyword.get_values(hooks, hook) do
        GenServer.cast(self, function.(message, client))
      end
    end
    {:noreply, client}
  end

  def handle_cast({:join, channel}, %Client{connection: connection, channels: channels} = client) do
    Connection.send_message("JOIN #{channel}", connection)
    {:noreply, %Client{client | channels: [channel | channels]}}
  end

  def handle_cast({:join, channel, key}, %Client{connection: connection, channels: channels} = client) do
    Connection.send_message("JOIN #{channel} #{key}", connection)
    {:noreply, %Client{client | channels: [channel | channels]}}
  end

  def handle_cast({:part, channel}, %Client{connection: connection, channels: channels} = client) do
    Connection.send_message("PART #{channel}", connection)
    {:noreply, %Client{client | channels: channels -- channel}}
  end

  def handle_cast({:part, channel, message}, %Client{connection: connection, channels: channels} = client) do
    Connection.send_message("PART #{channel} :#{message}", connection)
    {:noreply, %Client{client | channels: channels -- channel}}
  end

  def handle_cast({:nick, nickname}, %Client{connection: connection} = client) do
    Connection.send_message("NICK #{nickname}", connection)
    {:noreply, %Client{client | nickname: nickname}}
  end

  def handle_cast({:privmsg, target, message}, %Client{connection: connection} = client) do
    Connection.send_message("PRIVMSG #{target} :#{message}", connection)
    {:noreply, client}
  end

  def handle_cast({:ctcp, target, message}, %Client{connection: connection} = client) do
    Connection.send_message("PRIVMSG #{target} :#{<<1, message, 1>>}", connection)
    {:noreply, client}
  end

  def handle_cast({:action, target, message}, %Client{connection: connection} = client) do
    Connection.send_message("PRIVMSG #{target} :#{<<1, "ACTION ", message, 1>>}", connection)
    {:noreply, client}
  end

  def handle_cast({:notice, target, message}, %Client{connection: connection} = client) do
    Connection.send_message("NOTICE #{target} :#{message}", connection)
    {:noreply, client}
  end

  def handle_cast(:quit, %Client{connection: connection} = client) do
    Connection.send_message("QUIT :Leaving", connection)
    {:noreply, client}
  end

  def handle_cast({:quit, message}, %Client{connection: connection} = client) do
    Connection.send_message("QUIT :#{message}", connection)
    {:noreply, client}
  end

  def handle_cast({:kick, channel, target}, %Client{connection: connection} = client) do
    Connection.send_message("KICK #{channel} #{target}", connection)
    {:noreply, client}
  end

  def handle_cast({:kick, channel, target, message}, %Client{connection: connection} = client) do
    Connection.send_message("KICK #{channel} #{target} :#{message}", connection)
    {:noreply, client}
  end

  def handle_cast({:mode, target, flags}, %Client{connection: connection} = client) do
    Connection.send_message("MODE #{target} #{flags}", connection)
    {:noreply, client}
  end

  def handle_cast({:mode, target, flags, args}, %Client{connection: connection} = client) do
    Connection.send_message("MODE #{target} #{flags} #{args}", connection)
    {:noreply, client}
  end

  def handle_cast({:invite, target, channel}, %Client{connection: connection} = client) do
    Connection.send_message("INVITE #{target} #{channel}", connection)
    {:noreply, client}
  end

  def handle_cast({:pong, args}, %Client{connection: connection} = client) do
    Connection.send_message("PONG #{args}", connection)
    {:noreply, client}
  end

  def handle_cast({:raw, message}, %Client{connection: connection} = client) do
    Connection.send_message(message, connection)
    {:noreply, client}
  end

  def handle_cast(:noreply, %Client{} = client), do: {:noreply, client}

  def handle_cast(collection, %Client{} = client) do
    Enum.map(collection, fn (action) -> GenServer.cast(self, action) end)
    {:noreply, client}
  end
end
