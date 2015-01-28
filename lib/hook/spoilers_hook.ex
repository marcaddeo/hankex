defmodule Hank.Hook.SpoilersHook do
  use Hank.Hook

  def handle_cast(%Message{command: :privmsg, target: target, sender: sender, params: message}, client) do
    if message =~ ~r/spoiler(?s)/ do
      Hank.privmsg(client, "#{sender}: pls no spoilers")
    end

    {:noreply, client}
  end
  def handle_cast(_, client), do: {:noreply, client}
end
