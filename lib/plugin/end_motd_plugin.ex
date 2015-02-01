defmodule Hank.Plugin.EndMotdPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.State
  alias Hank.Core.Client.Server, as: Client

  def handle_cast({_, %State{channels: channels} = client}, state) do
    Enum.each(channels, fn (channel) ->
      Client.send_message(client, "JOIN #{channel}")
    end)
    {:noreply, state}
  end
end
