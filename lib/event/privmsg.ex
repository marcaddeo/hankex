defmodule Hank.Event.Privmsg do
  use GenEvent
  alias Hank.Connection
  alias Hank.Message

  def handle_event({%Message{command: :privmsg} = message, state}, _) do
    %Message{target: target, sender: sender, params: message} = message
    display_message(target, sender, message)
    {:ok, state}
  end

  defp display_message("#" <> target, sender, message) do
    IO.puts("[##{target}] #{sender}: #{message}")
  end

  defp display_message(_, sender, <<1, message :: binary-size(7), 1>>) do
    IO.puts("[#{sender}] #{message}")
  end

  defp display_message(_, sender, message) do
    IO.puts("[#{sender}] #{message}")
  end

  def handle_event(_, state), do: {:ok, state}
end
