defmodule Hank.Plugin.AutoRejoinPlugin do
  use Hank.Core.Plugin
  alias Hank.Core.Client.State
  alias Hank.Core.Client.Server, as: Client

  @second   1000
  @minute   60 * @second
  @timeout  1  * @minute
  @max_rejoins_per_minute 3

  def handle_cast(data, []) do
    state = {0, now()}
    {:noreply, handle_kick(data, state)}
  end

  def handle_cast(data, state) do
    {:noreply, handle_kick(data, state)}
  end

  defp handle_kick({message, state}, {rj, since}) do
    %Message{target: target} = message
    %State{nickname: nick}   = state

    [channel | [target]] = String.split(target, " ")

    if target == nick do
      if rj < @max_rejoins_per_minute do
        if ((now()- since) > 60) do
          {rj, since} = {0, now()}
        else
          {rj, since} = {rj + 1, since}
        end

        :timer.sleep(5 * @second)
        Client.join(channel)
      else
        :timer.sleep(@timeout)
        Client.join(channel)

        {rj, since} = {0, now()}
      end
    end

    {rj, since}
  end

  defp now() do
    {megasecs, secs, _} = :erlang.now()
    megasecs * 1000000 + secs
  end
end
