defmodule Hank.Core.Channel do
  use GenServer
  alias Hank.Core.User
  alias Hank.Core.Channel

  defstruct [
    name: nil,
    topic: nil,
    users: %{},
  ]

  ############
  # Public Api
  ############

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def get(name) do
    GenServer.call(__MODULE__, {:get, name})
  end

  def add(name) do
    GenServer.cast(__MODULE__, {:add, name})
  end

  def remove(name) do
    GenServer.cast(__MODULE__, {:remove, name})
  end

  def names(channel, names) do
    GenServer.cast(__MODULE__, {:names, channel, names})
  end

  def joined(channel, nick) do
    GenServer.cast(__MODULE__, {:joined, channel, nick})
  end

  def parted(channel, nick) do
    GenServer.cast(__MODULE__, {:parted, channel, nick})
  end

  def topic(channel, topic) do
    GenServer.cast(__MODULE__, {:topic, channel, topic})
  end

  def mode(channel, modes, targets) do
    GenServer.cast(__MODULE__, {:mode, channel, modes, targets})
  end

  ###############
  # GenServer Api
  ###############
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def handle_call(:all, _, channels) do
    {:reply, Dict.to_list(channels), channels}
  end

  def handle_call({:get, name}, _, channels) do
    {:reply, Dict.get(channels, name), channels}
  end

  def handle_cast({:add, name}, channels) do
    {:noreply, Dict.put(channels, name, %Channel{name: name})}
  end

  def handle_cast({:remove, name}, channels) do
    {:noreply, Dict.delete(channels, name)}
  end

  def handle_cast({:names, channel, names}, channels) do
    channels = Dict.update!(channels, channel, fn (chan) ->
      %Channel{chan | users: parse_names(names, chan.users)}
    end)
    {:noreply, channels}
  end

  def handle_cast({:joined, channel, nick}, channels) do
    channels = Dict.update!(channels, channel, fn (chan) ->
      %Channel{chan | users: Dict.put(chan.users, nick, %User{nickname: nick})}
    end)
    {:noreply, channels}
  end

  def handle_cast({:parted, channel, nick}, channels) do
    channels = Dict.update!(channels, channel, fn (chan) ->
      %Channel{chan | users: Dict.drop(chan.users, [nick])}
    end)
    {:noreply, channels}
  end

  def handle_cast({:topic, channel, topic}, channels) do
    channels = Dict.update!(channels, channel, fn (chan) ->
      %Channel{chan | topic: topic}
    end)
    {:noreply, channels}
  end

  def handle_cast({:mode, channel, modes, targets}, channels) do
    channels = Dict.update!(channels, channel, fn (chan) ->
      %Channel{chan | users: parse_modes(modes, targets, chan.users)}
    end)
    {:noreply, channels}
  end

  defp parse_modes([], [], users), do: users
  defp parse_modes([mode | mode_tail], [target | target_tail], users) do
    users = Dict.update!(users, target, fn (user) ->
      permissions = case mode do
        "+q" -> [:owner | user.permission]
        "-q" -> user.permissions -- [:owner]

        "+a" -> [:admin | user.permissions]
        "-a" -> user.permissions -- [:admin]

        "+o" -> [:op | user.permissions]
        "-o" -> user.permissions -- [:op]

        "+h" -> [:halfop | user.permissions]
        "-h" -> user.permissions -- [:halfop]

        "+v" -> [:voice | user.permissions]
        "-v" -> user.permissions -- [:voice]
      end

      %User{user | permissions: permissions}
    end)

    parse_modes(mode_tail, target_tail, users)
  end
  defp parse_modes(modes, targets, users) do
    targets = String.split(targets, " ")

    Regex.scan(~r/[+-][q,a,o,h,v]+/, modes)
    |> List.flatten()
    |> Enum.map(fn (mode) ->
      operation = String.first(mode)
      modes     = String.slice(mode, 1..-1)
      modes     = String.split(modes, "", parts: String.length(modes))

      for mode <- modes do operation <> mode end
    end)
    |> List.flatten()
    |> parse_modes(targets, users)
  end

  defp parse_names([], users), do: users
  defp parse_names([head | tail], users) do
    parse_names(tail, Dict.put(users, head.nickname, head))
  end
  defp parse_names(names, users \\ %{}) do
    names = names
    |> String.split(" ")
    |> Enum.map(fn (nick) ->
      [nick, permission] = case nick do
        <<"~", nick :: binary>> -> [nick, :owner]
        <<"&", nick :: binary>> -> [nick, :admin]
        <<"@", nick :: binary>> -> [nick, :op]
        <<"%", nick :: binary>> -> [nick, :halfop]
        <<"+", nick :: binary>> -> [nick, :voice]
        nick -> [nick, :normal]
      end

      %User{nickname: nick, permissions: [permission]}
    end)
    |> parse_names(users)
  end
end
