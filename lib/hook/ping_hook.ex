defmodule Hank.Hook.PingHook do
  alias Hank.Message

  def run(%Message{params: params}, _) do
    {:raw, "PONG #{params}"}
  end
end
