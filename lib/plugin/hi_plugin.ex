defmodule Hank.Plugin.HiPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.State
  alias Hank.Core.Client.Server, as: Client

  @greetings [
    "hi",
    "h",
    "bonjour",
    "sup",
    "ni hao",
    "fuck off",
    "piss off",
  ]
  @count Enum.count(@greetings)

  def handle_cast({%Message{} = message, %State{nickname: nick}}, state) do
    %Message{target: target, sender: sender, params: message} = message

    if message =~ ~r/hi #{nick}/i do
      greeting = Enum.at(@greetings, :random.uniform(@count) - 1)
      Client.privmsg(target, "#{greeting} #{sender}")
    end

    {:noreply, state}
  end
end
