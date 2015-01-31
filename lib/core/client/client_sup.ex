defmodule Hank.Core.Client.Supervisor do
  use Supervisor
  require Logger
  alias Hank.Core.Client.Server
  alias Hank.Core.Client.State, as: ClientState
  alias Hank.Core.Connection.State, as: ConnectionState
  alias Hank.Core.Connection.Supervisor, as: ConnectionSupervisor

  def start_link({%ClientState{}, %ConnectionState{}} = state) do
    Logger.info("Starting Client Supervisor")
    return = {:ok, sup} = Supervisor.start_link(__MODULE__, state, name: __MODULE__)
    start_children(sup, state)
    return
  end

  def init(state) do
    supervise([], strategy: :one_for_one)
  end

  defp start_children(sup, {client, conn}) do
    {:ok, server} = Supervisor.start_child(sup, worker(Server, [client]))
    conn = %ConnectionState{conn | client: server}
    Supervisor.start_child(sup, supervisor(ConnectionSupervisor, [conn]))
  end
end
