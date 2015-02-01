defmodule Hank.Plugin.MaizePlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.State
  alias Hank.Core.Client.Server, as: Client

  def handle_cast({%Message{target: "#" <> _} = message, %State{} = client}, state) do
    %Message{target: target, params: message} = message

    if message =~ ~r/^[o]+[h]+$/ do
      Client.privmsg(target, "maize")
    end

    {:noreply, state}
  end
  def handle_cast(_, state), do: {:noreply, state}
end

