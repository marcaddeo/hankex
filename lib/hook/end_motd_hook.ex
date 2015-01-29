defmodule Hank.Hook.EndMotdHook do
  use Hank.Hook
  alias Hank.Client.State, as: Client

  @tag :end_motd_hook
  @version "0.0.1"

  def handle_cast(_, client) do
    %Client{channels: channels} = GenServer.call(client, :get_state)
    Enum.map(channels, fn (channel) -> Hank.join(client, channel) end)
    {:noreply, client}
  end
  def handle_cast(_, client), do: {:noreply, client}
end
