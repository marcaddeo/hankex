defmodule Hank.Plugin.VersionPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.Server, as: Client

  def handle_cast({%Message{sender: sender, params: message}, client}, state) do
    case message do
      <<1, "VERSION", 1>> ->
        # TODO: Put action version number in
        version = <<1, "VERSION Hank 0.0.1", 1>>
        Client.send_message(client, "NOTICE #{sender} :#{version}")
      _ -> :ok
    end

    {:noreply, state}
  end
end
