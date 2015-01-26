defmodule Hank.Hook.MaizeHook do
  alias Hank.Message

  def run(%Message{command: :privmsg, target: target, params: message}, _) do
    if message =~ ~r/^[o]+[h]+$/ do
      {:privmsg, target, "maize"}
    else
      :noreply
    end
  end
end
