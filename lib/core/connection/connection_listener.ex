defmodule Hank.Core.Connection.Listener do
  use GenServer
  require Logger
  alias Hank.Core.Connection.SocketAgent
  alias Hank.Core.Connection.Server, as: Client

  def start_link() do
    Logger.info("Starting Connection Listener")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, [], 0}
  end

  def handle_info(:timeout, _) do
    listen(SocketAgent.get_socket())
    {:noreply, []}
  end

  defp listen(socket) do
    case Socket.Stream.recv!(socket) do
      data when is_binary(data) ->
        Client.receive(data)
        listen(socket)
      nil ->
        :ok
    end
  end
end
