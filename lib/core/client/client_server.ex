defmodule Hank.Core.Client.Server do
  use GenServer
  require Logger
  alias Hank.Core.Parser
  alias Hank.Core.Channel
  alias Hank.Core.Message
  alias Hank.Core.Client.State
  alias Hank.Core.Plugin.Supervisor, as: PluginSupervisor
  alias Hank.Core.Connection.Server, as: Connection

  ############
  # Public API
  ############
  @doc """
  Identifies to NickServ with `password`
  """
  def identify(password) do
    GenServer.cast(__MODULE__, {:identify, password})
  end

  @doc """
  Send a USER command to the server with `nickname` and `realname`
  """
  def user(nickname, realname) do
    GenServer.cast(__MODULE__, {:user, nickname, realname})
  end

  @doc """
  Joins `channel`
  """
  def join(channel) do
    GenServer.cast(__MODULE__, {:join, channel})
  end

  @doc """
  Joins `channel` with `key` for the password
  state
  """
  def join(channel, key) do
    GenServer.cast(__MODULE__, {:join, channel, key})
  end

  @doc """
  Parts `channel`
  """
  def part(channel) do
    GenServer.cast(__MODULE__, {:part, channel})
  end

  @doc """
  Parts `channel` with a part `message`
  state
  """
  def part(channel, message) do
    GenServer.cast(__MODULE__, {:part, channel, message})
  end

  @doc """
  Changes the clients nickname to `nickname`
  """
  def nick(nickname) do
    GenServer.cast(__MODULE__, {:nick, nickname})
  end

  @doc """
  Sends a PRIVMSG `message` to `target`
  """
  def privmsg(target, message) do
    GenServer.cast(__MODULE__, {:privmsg, target, message})
  end

  @doc """
  Sends a CTCP `message` to `target`
  """
  def ctcp(target, message) do
    GenServer.cast(__MODULE__, {:ctcp, target, message})
  end

  @doc """
  Sends an ACTION ctcp `message` to `target`
  """
  def action(target, message) do
    GenServer.cast(__MODULE__, {:action, target, message})
  end

  @doc """
  Sends a NOTICE `message` to `target`
  """
  def notice(target, message) do
    GenServer.cast(__MODULE__, {:notice, target, message})
  end

  @doc """
  Sends the QUIT command to the server
  """
  def quit() do
    GenServer.cast(__MODULE__, :quit)
  end

  @doc """
  Sends a QUIT command to the server with a quit `message`
  """
  def quit(message) do
    GenServer.cast(__MODULE__, {:quit, message})
  end

  @doc """
  Kicks the `target` from the `channel`
  """
  def kick(channel, target) do
    GenServer.cast(__MODULE__, {:kick, channel, target})
  end

  @doc """
  Kicks the `target` from the `channel` with a kick `message`
  """
  def kick(channel, target, message) do
    GenServer.cast(__MODULE__, {:kick, channel, target, message})
  end

  @doc """
  Set the MODE of `target` to `flags`
  """
  def mode(target, flags) do
    GenServer.cast(__MODULE__, {:mode, target, flags})
  end

  @doc """
  Set the MODE of `target` to `flags` with `args`
  """
  def mode(target, flags, args) do
    GenServer.cast(__MODULE__, {:mode, target, flags, args})
  end

  @doc """
  Invite `target` to `channel`
  """
  def invite(target, channel) do
    GenServer.cast(__MODULE__, {:invite, target, channel})
  end

  @doc """
  Sends a PONG to the server with `args`
  """
  def pong(args) do
    GenServer.cast(__MODULE__, {:pong, args})
  end

  @doc """
  Sends a WHOIS request for `target`
  """
  def whois(target) do
    GenServer.cast(__MODULE__, {:whois, target})
  end

  @doc """
  Send a raw `message` to the server
  """
  def raw(message) do
    GenServer.cast(__MODULE__, {:raw, message})
  end

  def connect(), do: GenServer.cast(__MODULE__, :connected)
  def receive(data), do: GenServer.cast(__MODULE__, {:message, data})

  ###############
  # GenServer API
  ###############
  def start_link(%State{} = state) do
    Logger.info("Starting Client Server")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_cast(:connected, %State{nickname: nick, realname: name, plugins: plugins} = state) do
    import Supervisor.Spec

    # Register with the IRC server
    user(nick, name)
    nick(nick)

    # Start the Plugin Supervisor
    child = supervisor(PluginSupervisor, [plugins])
    Supervisor.start_child(Hank.Core.Client.Supervisor, child)

    {:noreply, state}
  end

  def handle_cast({:message, data}, state) do
    IO.puts String.strip(data)

    message = Parser.parse(data)
    handle_message(message, state)
    PluginSupervisor.handle_message(message, state)
    {:noreply, state}
  end

  def handle_cast({:user, nickname, realname}, %State{} = client) do
    Connection.send("USER #{nickname} 0 * :#{realname}")
    {:noreply, client}
  end

  def handle_cast({:join, channel}, client) do
    Connection.send("JOIN #{channel}")
    {:noreply, client}
  end

  def handle_cast({:join, channel, key}, client) do
    Connection.send("JOIN #{channel} #{key}")
    {:noreply, client}
  end

  def handle_cast({:part, channel}, client) do
    Connection.send("PART #{channel}")
    {:noreply, client}
  end

  def handle_cast({:part, channel, message}, client) do
    Connection.send("PART #{channel} :#{message}")
    {:noreply, client}
  end

  def handle_cast({:nick, nickname}, %State{} = client) do
    Connection.send("NICK #{nickname}")
    {:noreply, %State{client | nickname: nickname}}
  end

  def handle_cast({:privmsg, target, message}, %State{} = client) do
    Connection.send("PRIVMSG #{target} :#{message}")
    {:noreply, client}
  end

  def handle_cast({:identify, password}, %State{} = client) do
    Connection.send("PRIVMSG NickServ :IDENTIFY #{password}")
    {:noreply, client}
  end

  def handle_cast({:ctcp, target, message}, %State{} = client) do
    Connection.send("PRIVMSG #{target} :#{<<1, message, 1>>}")
    {:noreply, client}
  end

  def handle_cast({:action, target, message}, %State{} = client) do
    Connection.send("PRIVMSG #{target} :#{<<1, "ACTION ", message, 1>>}")
    {:noreply, client}
  end

  def handle_cast({:notice, target, message}, %State{} = client) do
    Connection.send("NOTICE #{target} :#{message}")
    {:noreply, client}
  end

  def handle_cast(:quit, %State{} = client) do
    Connection.send("QUIT :Leaving")
    {:noreply, client}
  end

  def handle_cast({:quit, message}, %State{} = client) do
    Connection.send("QUIT :#{message}")
    {:noreply, client}
  end

  def handle_cast({:kick, channel, target}, %State{} = client) do
    Connection.send("KICK #{channel} #{target}")
    {:noreply, client}
  end

  def handle_cast({:kick, channel, target, message}, %State{} = client) do
    Connection.send("KICK #{channel} #{target} :#{message}")
    {:noreply, client}
  end

  def handle_cast({:mode, target, flags}, %State{} = client) do
    Connection.send("MODE #{target} #{flags}")
    {:noreply, client}
  end

  def handle_cast({:mode, target, flags, args}, %State{} = client) do
    Connection.send("MODE #{target} #{flags} #{args}")
    {:noreply, client}
  end

  def handle_cast({:invite, target, channel}, %State{} = client) do
    Connection.send("INVITE #{target} #{channel}")
    {:noreply, client}
  end

  def handle_cast({:pong, args}, %State{} = client) do
    Connection.send("PONG #{args}")
    {:noreply, client}
  end

  def handle_cast({:whois, target}, %State{} = client) do
    Connection.send("WHOIS #{target}")
    {:noreply, client}
  end

  def handle_cast({:raw, message}, %State{} = client) do
    Connection.send(message)
    {:noreply, client}
  end

  #############
  # Private Api
  #############
  defp handle_message(message, %State{nickname: nick}) do
    case message do
      %Message{command: :join, sender: ^nick, params: channel} ->
        Channel.add(channel)
      %Message{command: :join, params: channel, sender: nickname} ->
        Channel.joined(channel, nickname)

      %Message{command: :part, sender: ^nick, params: channel} ->
        Channel.remove(channel)
      %Message{command: :part, target: channel, sender: nickname} ->
        Channel.parted(channel, nickname)

      %Message{command: :"332", params: topic, target: target} ->
        [_ | [channel]] = String.split(target, " ")
        Channel.topic(channel, topic)

      %Message{command: :"353", params: names, target: target} ->
        [_ | [channel]] = String.split(target, ~r/ [^\s] /)
        Channel.names(channel, names)

      %Message{command: :mode, params: <<"#", _ :: binary>> = params} ->
        [channel, modes, targets] = String.split(params, " ", parts: 3)
        Channel.mode(channel, modes, targets)

      _ -> :ok
    end
  end
end
