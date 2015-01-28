defmodule Hank.Hook.MaizeHook do
  use Hank.Hook

  @tag :maize_hook
  @version "0.0.1"

  def handle_cast(%Message{command: :privmsg, target: target, params: message}, client) do
    if message =~ ~r/^[o]+[h]+$/ do
      Hank.privmsg(client, target, "maize")
    end

    {:noreply, client}
  end
  def handle_cast(_, client), do: {:noreply, client}
end
