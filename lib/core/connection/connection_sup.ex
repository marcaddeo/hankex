defmodule Hank.Core.Connection.Supervisor do
  use Supervisor
  require Logger
  alias Hank.Core.Connection.State
  alias Hank.Core.Connection.Server
  alias Hank.Core.Connection.Listener

  def start_link(%State{} = state) do
    Logger.info("Starting Connection Supervisor")
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    children = [
      worker(Server, [state]),
      worker(Listener, []),
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
