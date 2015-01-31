defmodule Hank.Core.Connection.Supervisor do
  use Supervisor
  require Logger
  alias Hank.Core.Connection.State
  alias Hank.Core.Connection.Server
  alias Hank.Core.Connection.Listener

  def start_link(%State{} = state) do
    Logger.info("Starting Connection Supervisor")
    return = {:ok, sup} = Supervisor.start_link(__MODULE__, state, name: __MODULE__)
    start_workers(sup, state)
    return
  end

  def init(state) do
    supervise([], strategy: :one_for_one)
  end

  defp start_workers(sup, state) do
    {:ok, server} = Supervisor.start_child(sup, worker(Server, [state]))
    socket = GenServer.call(server, :socket)
    Supervisor.start_child(sup, worker(Listener, [{server, socket}]))
  end
end
