defmodule Hank.Plugin.HiPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.State
  alias Hank.Core.Client.Server, as: Client

  @greetings ["hi", "bonjour", "sup", "ni hao", "fuck off"]
  @count Enum.count(@greetings)

  def handle_cast({%Message{} = message, %State{nickname: nick} = client}, state) do
    %Message{target: target, sender: sender, params: message} = message

    if message =~ ~r/hi #{nick}/i do
      greeting = Enum.at(@greetings, :random.uniform(@count) - 1)
      Client.send_message(client, "PRIVMSG #{target} :#{greeting} #{sender}")
    end

    {:noreply, state}
  end
end