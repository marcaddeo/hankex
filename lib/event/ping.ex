defmodule Hank.Event.Ping do
  use GenEvent
  alias Hank.Connection
  alias Hank.Message

  def handle_event({%Message{command: :ping, params: pong} = message, state}, _) do
    Connection.send_message(state, "PONG #{pong}")
    {:ok, state}
  end

  def handle_event(_, state), do: {:ok, state}
end
