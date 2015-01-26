defmodule Hank do
  alias Hank.Client
  alias Hank.Connection
  alias Hank.Connection.State, as: ConnectionState
  alias Hank.Client.State, as: ClientState

  def start() do
    state = %ConnectionState{hostname: "irc.rizon.net"}
    client     = %ClientState{
      nickname: "MaizeBot",
      realname: "Maize",
      channels: ["#murdock"],
      hooks:    [
        {:handshake,  &Hank.Hook.HandshakeHook.run/2},
        {:ping,       &Hank.Hook.PingHook.run/2},
        {:"376",      &Hank.Hook.EndMotdHook.run/2},
        {:privmsg,    &Hank.Hook.VersionHook.run/2},
        {:privmsg,    &Hank.Hook.DisplayPrivmsgHook.run/2},
        {:privmsg,    &Hank.Hook.MaizeHook.run/2},
      ]
    }

    {:ok, client}     = Client.start_link(client)
    {:ok, connection} = Connection.start_link(%ConnectionState{state | client: client})
    {:ok, client, connection}
  end

  def load_hook(client, hook, function) do
    GenServer.cast(client, {:load_hook, hook, function})
  end
end
