defmodule Hank.Hook.VersionHook do
  alias Hank.Message

  def run(%Message{command: :privmsg} = message, _) do
    %Message{sender: sender, params: message} = message

    case message do
      <<1, "VERSION", 1>> ->
        version = <<1, "VERSION Elixir " <> System.version(), 1>>
        {:notice, sender, version}
      _ -> :noreply
    end
  end
end
