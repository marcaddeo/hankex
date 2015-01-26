defmodule Hank do
  alias Hank.Client
  alias Hank.Connection
  alias Hank.Connection.State, as: ConnectionState
  alias Hank.Client.State, as: ClientState

  def start() do
    state  = %ConnectionState{hostname: "irc.x-zen.cx"}
    client = %ClientState{
      nickname: "Hank",
      realname: "Hank",
      channels: ["#blah"],
      hooks:    [
        {:handshake,  &Hank.Hook.HandshakeHook.run/2},
        {:ping,       &Hank.Hook.PingHook.run/2},
        {:"376",      &Hank.Hook.EndMotdHook.run/2},
        {:privmsg,    &Hank.Hook.VersionHook.run/2},
        {:privmsg,    &Hank.Hook.DisplayPrivmsgHook.run/2},
        {:privmsg,    &Hank.Hook.MaizeHook.run/2},
        {:privmsg,    &Hank.Hook.SpoilersHook.run/2},
      ]
    }

    {:ok, client}     = Client.start_link(client)
    {:ok, connection} = Connection.start_link(%ConnectionState{state | client: client})
    {:ok, client, connection}
  end

  def load_hook(client, hook, function) do
    GenServer.cast(client, {:load_hook, hook, function})
  end

  def join(client, channel) do
   GenServer.cast(client, {:raw, "JOIN #{channel}"})
  end

  def join(client, channel, key) do
   GenServer.cast(client, {:raw, "JOIN #{channel} #{key}"})
  end
end
