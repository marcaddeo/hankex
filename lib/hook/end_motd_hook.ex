defmodule Hank.Hook.EndMotdHook do
  alias Hank.Message
  alias Hank.Client.State, as: Client

  def run(%Message{command: :"376"}, %Client{channels: channels}) do
    Enum.map(channels, fn (channel) -> {:raw, "JOIN #{channel}"} end)
  end
end
