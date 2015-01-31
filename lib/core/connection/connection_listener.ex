defmodule Hank.Core.Connection.Listener do
  use GenServer
  require Logger

  def start_link(state) do
    Logger.info("Starting Connection Listener")
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state, 0}
  end

  def handle_info(:timeout, {server, socket} = state) do
    listen(state)
    {:noreply, state}
  end

  defp listen({server, socket} = state) do
    case Socket.Stream.recv!(socket) do
      data when is_binary(data) ->
        GenServer.cast(server, {:receive, data})
        listen(state)
      nil ->
        :ok
    end
  end
end
