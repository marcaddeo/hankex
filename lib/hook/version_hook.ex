defmodule Hank.Hook.VersionHook do
  use Hank.Hook

  def handle_cast(%Message{command: :privmsg, sender: sender, params: message}, client) do
    case message do
      <<1, "VERSION", 1>> ->
        version = <<1, "VERSION Elixir " <> System.version(), 1>>
        Hank.notice(client, sender, version)
      _ -> :ok
    end

    {:noreply, client}
  end
  def handle_cast(_, client), do: {:noreply, client}
end
