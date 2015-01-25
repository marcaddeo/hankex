defmodule Hank.Hook.MaizeHook do
  alias Hank.Message

  def run(%Message{command: :privmsg} = message, _) do
    %Message{target: target, sender: sender, params: message} = message

    if message =~ ~r/^[o]+[h]+$/ do
      {:privmsg, target, "maize"}
    else
      :noreply
    end
  end
end
