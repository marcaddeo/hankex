defmodule Hank.Hook.HandshakeHook do
  alias Hank.Client.State, as: Client

  def run(_, %Client{nickname: nickname, realname: realname}) do
    [
      {:raw, "NICK #{nickname}"},
      {:raw, "USER #{nickname} 0 * :#{realname}"},
      :remove_hook,
    ]
  end
end
