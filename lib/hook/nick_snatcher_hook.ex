defmodule Hank.Hook.NickSnatcherHook do
  alias Hank.Message
  alias Hank.Client.State, as: Client

  @second 1000
  @minute 60 * @second
  @hour   60 * @minute

  def run(%Message{command: :"433"}, %Client{extra: extra}) do
    :timer.sleep(@minute)
    {:nick, extra.nick_snatcher.nickname}
  end

  def run(%Message{command: :nick}, %Client{nickname: nickname, extra: extra}) do
    IO.puts("My nickname is #{nickname}")
    :noreply
  end
end
