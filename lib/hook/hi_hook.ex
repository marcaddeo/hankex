defmodule Hank.Hook.HiHook do
  use Hank.Hook
  alias Hank.Client.State, as: Client

  @tag :hi_hook
  @version "0.0.1"
  @greetings ["hi", "bonjour", "sup", "ni hao", "fuck off"]
  @count Enum.count(@greetings)

  def handle_cast(%Message{command: :privmsg, target: "#" <> _} = message, client) do
    %Message{target: target, sender: sender, params: message} = message
    %Client{nickname: nickname} = GenServer.call(client, :get_state)

    if message =~ ~r/hi #{nickname}/i do
      greeting = Enum.at(@greetings, :random.uniform(@count) - 1)
      Hank.privmsg(client, target, "#{greeting} #{sender}")
    end

    {:noreply, client}
  end
  def handle_cast(_, client), do: {:noreply, client}
end
