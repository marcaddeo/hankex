defmodule Hank.Core.Connection.SocketAgent do
  def start_link() do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def get_socket(), do: Agent.get(__MODULE__, fn (socket) -> socket end)
  def set_socket(socket), do: Agent.update(__MODULE__, fn (_) -> socket end)
  def clear_socket(), do: set_socket(nil)
end
