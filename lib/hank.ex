defmodule Hank do
  alias Hank.Connection
  alias Hank.Connection.State

  def start() do
    state = %State{
      hostname: "irc.rizon.net",
      nickname: "MaizeBot",
      realname: "Maize",
      channels: ["#rainbow.tv"]
    }

    {:ok, event_manager} = GenEvent.start_link()

    GenEvent.add_handler(event_manager, Hank.Event.Init, [])
    GenEvent.add_handler(event_manager, Hank.Event.Ping, [])
    GenEvent.add_handler(event_manager, Hank.Event.EndMotd, [])
    GenEvent.add_handler(event_manager, Hank.Event.Privmsg, [])

    Connection.start_link(%State{state | event_manager: event_manager})
  end
end
