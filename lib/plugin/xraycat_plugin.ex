defmodule Hank.Plugin.XrayCatPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.User
  alias Hank.Core.Channel
  alias Hank.Core.Client.Server, as: Client

  @channel "#rainbow.tv"

  def handle_cast({
    %Message{
      target: @channel,
      params: "@stream " <> stream,
      sender: sender
    }, _},
    state
  ) do
    if has_permission?(sender, [:admin, :owner]) do
      Client.privmsg(@channel, "Changing stream to #{stream}")
    end

    {:noreply, state}
  end

  def handle_cast(_, state), do: {:noreply, state}

  defp has_permission?(user, allowed_permissions) do
      channel = Channel.get(@channel)
      %User{permissions: permissions} = Dict.fetch!(channel.users, user)

      Enum.any?(permissions, &(&1 in allowed_permissions))
  end
end

