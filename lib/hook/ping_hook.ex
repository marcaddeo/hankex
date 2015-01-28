defmodule Hank.Hook.PingHook do
  use Hank.Hook

  @tag :ping_hook
  @version "0.0.1"

  def handle_cast(%Message{params: params}, client) do
    Hank.pong(client, params)
    {:noreply, client}
  end
  def handle_cast(_, client), do: {:noreply, client}
end
