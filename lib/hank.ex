defmodule Hank do
  use Application
  alias Hank.Core.Plugin.State, as: Plugin
  alias Hank.Core.Client.State, as: ClientState
  alias Hank.Core.Connection.State, as: ConnectionState
  alias Hank.Core.Client.Supervisor, as: ClientSupervisor

  def start(_, _) do
    import Application, only: [get_env: 2]
    config     = get_env(:hank, :connection)
    connection = %ConnectionState{hostname: config[:hostname]}
    config     = get_env(:hank, :client)
    client     = %ClientState{
      nickname: config[:nickname],
      password: config[:password],
      realname: config[:realname],
      channels: config[:channels],
      plugins: [
        %Plugin{name: :ping_plugin, module: Hank.Plugin.PingPlugin, hooks: [:ping]},
        %Plugin{name: :end_motd_plugin, module: Hank.Plugin.EndMotdPlugin, hooks: [:"376"]},
        %Plugin{name: :version_plugin, module: Hank.Plugin.VersionPlugin, hooks: [:privmsg]},
      ]
    }

    ClientSupervisor.start_link({client, connection})
  end
end
