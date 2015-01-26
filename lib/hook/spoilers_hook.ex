defmodule Hank.Hook.SpoilersHook do
  alias Hank.Message

  def run(%Message{command: :privmsg, target: target, sender: sender, params: message}, _) do
    if message =~ ~r/spoiler(?s)/ do
      {:privmsg, target, "#{sender}: pls no spoilers"}
    else
      :noreply
    end
  end
end
