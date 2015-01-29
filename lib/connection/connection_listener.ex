defmodule Hank.Connection.ConnectionListener do
  use GenServer
  alias Hank.Connection.State

  @supervisor Hank.Connection.ConnectionSupervisor

  def start_link(%State{} = state) do
    IO.puts "Starting ConnectionListener"
    GenServer.start_link(__MODULE__, state)
  end

  def init(%State{} = state) do
    {:ok, state, 0}
  end

  def handle_info(:timeout, %State{} = state) do
    state = %State{state | socket: @supervisor.get_socket()}
    listen(state)
    {:noreply, state}
  end

  defp listen(%State{socket: socket} = state) do
    case Socket.Stream.recv!(socket) do
      data when is_binary(data) ->
        GenServer.cast(@supervisor.get_connection_server(), {:receive, data})
        listen(state)
      nil ->
        :ok
    end
  end
end
