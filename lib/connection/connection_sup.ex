defmodule Hank.Connection.ConnectionSupervisor do
  use Supervisor
  alias Hank.Connection.State
  alias Hank.Connection.ConnectionServer
  alias Hank.Connection.ConnectionListener

  @supervisor Hank.Supervisor

  def start_link(%State{} = state) do
    IO.puts "Starting Connection Supervisor"
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    children = [
      worker(ConnectionServer, [state]),
      worker(ConnectionListener, [state]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  def get_client() do
    @supervisor.get_client()
  end

  def send_message(message) do
    GenServer.cast(get_connection_server(), {:send, message})
  end

  def get_connection_server() do
    pid = for {ConnectionServer, pid, _, _} <- Supervisor.which_children(__MODULE__), do: pid
    hd(pid)
  end

  def get_socket() do
    GenServer.call(get_connection_server(), :socket)
  end
end
