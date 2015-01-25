defmodule Hank.Event.EndMotd do
  use GenEvent
  alias Hank.Connection
  alias Hank.Message

  def handle_event({%Message{command: :"376"}, state}, _) do
    Enum.map(state.channels, fn (channel) ->
      Connection.send_message(state, "JOIN #{channel}")
    end)
    {:ok, state}
  end

  def handle_event(_, state), do: {:ok, state}
end
