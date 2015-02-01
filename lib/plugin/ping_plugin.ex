defmodule Hank.Plugin.PingPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.Server, as: Client

  def handle_cast({%Message{params: params}, client}, state) do
    Client.send_message(client, "PONG :#{params}")
    {:noreply, state}
  end
end
