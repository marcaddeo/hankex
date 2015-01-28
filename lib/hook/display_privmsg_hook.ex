defmodule Hank.Hook.DisplayPrivmsgHook do
  use Hank.Hook

  @tag :display_privmsg_hook
  @version "0.0.1"

  def handle_cast(%Message{command: :privmsg} = message, client) do
    %Message{target: target, sender: sender, params: message} = message

    display_message(target, sender, message)
    {:noreply, client}
  end
  def handle_cast(_, client), do: {:noreply, client}

  defp display_message("#" <> target, sender, message) do
    IO.puts("[##{target}] #{sender}: #{message}")
  end

  defp display_message(_, _, <<1, _ :: binary-size(7), 1>>) do
    :ok
  end

  defp display_message(_, sender, message) do
    IO.puts("[#{sender}] #{message}")
  end
end
