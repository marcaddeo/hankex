defmodule Hank.Core.Client.Supervisor do
  use Supervisor
  require Logger
  alias Hank.Core.Client.Server
  alias Hank.Core.Client.State, as: ClientState
  alias Hank.Core.Connection.State, as: ConnectionState
  alias Hank.Core.Connection.Supervisor, as: ConnectionSupervisor

  def start_link({%ClientState{}, %ConnectionState{}} = state) do
    Logger.info("Starting Client Supervisor")
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init({%ClientState{} = client, %ConnectionState{} = conn}) do
    children = [
      worker(Server, [client]),
      supervisor(ConnectionSupervisor, [conn]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
