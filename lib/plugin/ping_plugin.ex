defmodule Hank.Plugin.PingPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.Server, as: Client

  def handle_cast({%Message{params: params}, _}, state) do
    Client.pong(params)
    {:noreply, state}
  end
end
