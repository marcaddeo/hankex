defmodule Hank.Event.Init do
  use GenEvent
  alias Hank.Connection
  alias Hank.Connection.State

  def handle_event({:init, %State{} = state}, _) do
    %State{nickname: nickname, realname: realname} = state
    Connection.send_message(state, "NICK #{nickname}")
    Connection.send_message(state, "USER #{nickname} 0 * :#{realname}")

    :remove_handler
  end

  def handle_event(_, state), do: {:ok, state}
end
