defmodule Hank do
  use Supervisor
  use Hank.Commands
  alias Hank.Client
  alias Hank.Connection.ConnectionSupervisor
  alias Hank.Connection.State, as: ConnectionState
  alias Hank.Client.State, as: ClientState

  def start() do
    config     = Mix.Config.read("config/config.exs")
    connection = %ConnectionState{hostname: config[:connection][:hostname]}
    client     = %ClientState{
      nickname: config[:client][:nickname],
      realname: config[:client][:realname],
      channels: config[:client][:channels],
      hooks:    [
        {:ping,     &Hank.Hook.PingHook.register/1},
        {:"376",    &Hank.Hook.EndMotdHook.register/1},
        {:privmsg,  &Hank.Hook.VersionHook.register/1},
        {:privmsg,  &Hank.Hook.DisplayPrivmsgHook.register/1},
        {:privmsg,  &Hank.Hook.MaizeHook.register/1},
        {:privmsg,  &Hank.Hook.SpoilersHook.register/1},
        {:privmsg,  &Hank.Hook.HiHook.register/1},
      ]
    }

    Supervisor.start_link(__MODULE__, {client, connection}, name: __MODULE__)
  end

  def init({client, connection}) do
    children = [
      worker(Client, [client]),
      supervisor(ConnectionSupervisor, [connection]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  def get_client() do
    pid = for {Client, pid, _, _} <- Supervisor.which_children(__MODULE__), do: pid
    hd(pid)
  end
end
