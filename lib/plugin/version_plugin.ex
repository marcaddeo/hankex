defmodule Hank.Plugin.VersionPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.Server, as: Client

  def handle_cast({%Message{sender: sender, raw_params: message}, _}, state) do
    case message do
      <<1, "VERSION", 1>> ->
        # TODO: Put actual version number in
        version = <<1, "VERSION Hank 0.0.1", 1>>
        Client.notice(sender, version)
      _ -> :ok
    end

    {:noreply, state}
  end
end
