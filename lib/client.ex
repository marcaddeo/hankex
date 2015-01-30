defmodule Hank.Client do
  @moduledoc """
  `Hank.Client` is the brains of the operation. It processes messages from the
  IRC server and calls hooks if they match the command issued by the IRC server
  and sends commands to the server depending on the response from the hook.
  """

  use GenServer
  alias Hank.Message
  alias Hank.Connection
  alias Hank.Client.State, as: Client

  @connection Hank.Connection.ConnectionSupervisor

  defmodule State do
    @moduledoc """
    The state of the client
    """

    defstruct [
      connection:  nil,
      channels:    [],
      nickname:    nil,
      realname:    nil,
      hooks:       [],
      extra:       [],
    ]
  end

  @doc """
  Starts the GenServer for the client
  """
  def start_link(%Client{} = client) do
    GenServer.start_link(__MODULE__, client)
  end

  def init(%Client{hooks: hooks} = client) do
    hooks = hooks
      |> Enum.map(fn ({hook, function}) ->
        {:ok, tag, pid} = function.(self)
        {hook, {pid, function, tag}}
      end)

    {:ok, %Client{client | hooks: hooks}}
  end

  def handle_call(:get_state, _, %Client{} = client) do
    {:reply, client, client}
  end

  def handle_cast(:connected, %Client{nickname: nick, realname: name} = client) do
    password = Mix.Config.read!("config/config.exs")[:nickserv][:password]

    self
      |> Hank.nick(nick)
      |> Hank.user(nick, name)
      |> Hank.identify(password)

    {:noreply, client}
  end

  @doc """
  Update the extra configuration section of the client state
  """
  def handle_cast({:update_extra, extra}, %Client{} = client) do
    {:noreply, %Client{client | extra: extra}}
  end

  @doc """
  Loads a hook into the client while running
  """
  def handle_cast({:load_hook, hook, function}, %Client{hooks: hooks} = client) do
    {:ok, tag, pid} = function.(self)
    {:noreply, %Client{client | hooks: [{hook, {pid, function, tag}} | hooks]}}
  end

  @doc """
  Removes any hooks that match `hook`
  TODO: Garbage collection!
  """
  def handle_cast({:remove_hook, hook}, %Client{hooks: hooks} = client) do
    {:noreply, %Client{client | hooks: Keyword.delete(hooks, hook)}}
  end

  @doc """
  Removes a hook that matching by `hook` name and `function`
  """
  def handle_cast({:remove_hook, hook, function}, %Client{hooks: hooks} = client) do
    {:noreply, %Client{client | hooks: Keyword.delete(hooks, hook, function)}}
  end

  @doc """
  Parses IRC messages from the server and runs the respective hook for that IRC
  command
  """
  def handle_cast(%Message{command: hook} = message, %Client{hooks: hooks} = client) do
    if Keyword.has_key?(hooks, hook) do
      for {pid, _, _} <- Keyword.get_values(hooks, hook) do
        GenServer.cast(pid, message)
      end
    end
    {:noreply, client}
  end

  @doc """
  Send a USER command to the server with nickname and realname
  """
  def handle_cast({:user, nickname, realname}, %Client{} = client) do
    @connection.send_message("USER #{nickname} 0 * :#{realname}")
    {:noreply, client}
  end

  @doc """
  Joins a channel and updates the channel list in the client state
  """
  def handle_cast({:join, channel}, %Client{channels: channels} = client) do
    @connection.send_message("JOIN #{channel}")
    {:noreply, %Client{client | channels: [channel | channels]}}
  end

  @doc """
  Joins a password protected channel and updates the channel list in the client
  state
  """
  def handle_cast({:join, channel, key}, %Client{channels: channels} = client) do
    @connection.send_message("JOIN #{channel} #{key}")
    {:noreply, %Client{client | channels: [channel | channels]}}
  end

  @doc """
  Parts a channel and updates the channel list in the client state
  """
  def handle_cast({:part, channel}, %Client{channels: channels} = client) do
    @connection.send_message("PART #{channel}")
    {:noreply, %Client{client | channels: channels -- channel}}
  end

  @doc """
  Parts a channel with a part message and updates the channel list in the client
  state
  """
  def handle_cast({:part, channel, message}, %Client{channels: channels} = client) do
    @connection.send_message("PART #{channel} :#{message}")
    {:noreply, %Client{client | channels: channels -- channel}}
  end

  @doc """
  Changes the bots nickname, and updates the nickname in the client state
  """
  def handle_cast({:nick, nickname}, %Client{} = client) do
    @connection.send_message("NICK #{nickname}")
    {:noreply, %Client{client | nickname: nickname}}
  end

  @doc """
  Sends a PRIVMSG message to target
  """
  def handle_cast({:privmsg, target, message}, %Client{} = client) do
    @connection.send_message("PRIVMSG #{target} :#{message}")
    {:noreply, client}
  end

  @doc """
  Identifies to NickServ
  """
  def handle_cast({:identify, password}, %Client{} = client) do
    @connection.send_message("PRIVMSG NickServ :IDENTIFY #{password}")
    {:noreply, client}
  end

  @doc """
  Sends a CTCP message to target
  """
  def handle_cast({:ctcp, target, message}, %Client{} = client) do
    @connection.send_message("PRIVMSG #{target} :#{<<1, message, 1>>}")
    {:noreply, client}
  end

  @doc """
  Sends an ACTION ctcp message to target
  """
  def handle_cast({:action, target, message}, %Client{} = client) do
    @connection.send_message("PRIVMSG #{target} :#{<<1, "ACTION ", message, 1>>}")
    {:noreply, client}
  end

  @doc """
  Sends a NOTICE message to target
  """
  def handle_cast({:notice, target, message}, %Client{} = client) do
    @connection.send_message("NOTICE #{target} :#{message}")
    {:noreply, client}
  end

  @doc """
  Sends the QUIT command to the server
  """
  def handle_cast(:quit, %Client{} = client) do
    @connection.send_message("QUIT :Leaving")
    {:noreply, client}
  end

  @doc """
  Sends a QUIT command to the server with a quit message
  """
  def handle_cast({:quit, message}, %Client{} = client) do
    @connection.send_message("QUIT :#{message}")
    {:noreply, client}
  end

  @doc """
  Kicks the target from the channel
  """
  def handle_cast({:kick, channel, target}, %Client{} = client) do
    @connection.send_message("KICK #{channel} #{target}")
    {:noreply, client}
  end

  @doc """
  Kicks the target from the channel with a kick message
  """
  def handle_cast({:kick, channel, target, message}, %Client{} = client) do
    @connection.send_message("KICK #{channel} #{target} :#{message}")
    {:noreply, client}
  end

  @doc """
  Set the MODE of target to flags
  """
  def handle_cast({:mode, target, flags}, %Client{} = client) do
    @connection.send_message("MODE #{target} #{flags}")
    {:noreply, client}
  end

  @doc """
  Set the MODE of target to flags with args
  """
  def handle_cast({:mode, target, flags, args}, %Client{} = client) do
    @connection.send_message("MODE #{target} #{flags} #{args}")
    {:noreply, client}
  end

  @doc """
  Invite target to channel
  """
  def handle_cast({:invite, target, channel}, %Client{} = client) do
    @connection.send_message("INVITE #{target} #{channel}")
    {:noreply, client}
  end

  @doc """
  Sends a PONG to the server with args
  """
  def handle_cast({:pong, args}, %Client{} = client) do
    @connection.send_message("PONG #{args}")
    {:noreply, client}
  end

  @doc """
  Sends a WHOIS request for target
  """
  def handle_cast({:whois, target}, %Client{} = client) do
    @connection.send_message("WHOIS #{target}")
    {:noreply, client}
  end

  @doc """
  Send a raw message to the server
  """
  def handle_cast({:raw, message}, %Client{} = client) do
    @connection.send_message(message)
    {:noreply, client}
  end

  @doc """
  Handle a :noreply from a hook
  """
  def handle_cast(:noreply, %Client{} = client), do: {:noreply, client}

  @doc """
  Iterate over a collection of hook responses and execute them
  """
  def handle_cast(collection, %Client{} = client) do
    Enum.map(collection, fn (action) -> GenServer.cast(self, action) end)
    {:noreply, client}
  end
end
