defmodule Hank.Hook.HiHook do
  alias Hank.Message
  alias Hank.Client.State, as: Client

  @greetings ["hi", "bonjour", "sup", "ni hao", "fuck off"]
  @count Enum.count(@greetings)

  def run(%Message{command: :privmsg, target: "#" <> _} = message, %Client{} = client) do
    %Message{target: target, sender: sender, params: message} = message

    if message =~ ~r/hi #{client.nickname}/i do
      greeting = Enum.at(@greetings, :random.uniform(@count) - 1)
      {:privmsg, target, "#{greeting} #{sender}"}
    else
      :noreply
    end
  end

  def run(_, _), do: :noreply
end
