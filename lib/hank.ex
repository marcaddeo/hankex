defmodule Hank do
  use Application
  alias Hank.Core.Client.State, as: ClientState
  alias Hank.Core.Connection.State, as: ConnectionState
  alias Hank.Core.Client.Supervisor, as: ClientSupervisor

  def start(_, _) do
    import Application, only: [get_env: 2]
    config     = get_env(:hank, :connection)
    connection = %ConnectionState{hostname: get_env(:hank, :connection)[:hostname]}
    config     = get_env(:hank, :client)
    client     = %ClientState{
      nickname: config[:nickname],
      password: config[:password],
      realname: config[:realname],
      channels: config[:channels],
    }

    ClientSupervisor.start_link({client, connection})
  end
end
