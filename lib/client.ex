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

  def init(%Client{} = client) do
    {:ok, client}
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

  def handle_cast({:load_hook, hook, function}, client) do
    {:noreply, %Client{client | hooks: [{hook, function} | client.hooks]}}
  end

  def handle_cast({:remove_hook, hook}, %Client{} = client) do
    {:noreply, %Client{client | hooks: client.hooks -- hook}}
  end

  def handle_cast(%Message{command: hook} = message, %Client{hooks: hooks} = client) do
    if Keyword.has_key?(hooks, hook) do
      for function <- Keyword.get_values(hooks, hook) do
        GenServer.cast(self, function.(message, client))
      end
    end
    {:noreply, client}
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

  def handle_cast({:raw, message}, %Client{connection: connection} = client) do
    Connection.send_message(message, connection)
    {:noreply, client}
  end

  def handle_cast(collection, %Client{} = client) do
    Enum.map(collection, fn (action) -> GenServer.cast(self, action) end)
    {:noreply, client}
  end
end
