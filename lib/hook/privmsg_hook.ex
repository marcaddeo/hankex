defmodule Hank.Hook.PrivmsgHook do
  alias Hank.Message

  def run(%Message{command: :privmsg} = message, _) do
    %Message{target: target, sender: sender, params: message} = message

    display_message(target, sender, message)
  end

  defp display_message("#" <> target, sender, message) do
    IO.puts("[##{target}] #{sender}: #{message}")
    :noreply
  end

  defp display_message(_, sender, <<1, message :: binary-size(7), 1>>) do
    IO.puts("[#{sender}] #{message}")
    :noreply
  end

  defp display_message(_, sender, message) do
    IO.puts("[#{sender}] #{message}")
    :noreply
  end
end
