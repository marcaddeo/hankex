defmodule Hank.Core.Client.Server do
  use GenServer
  alias Hank.Core.Client.State
  alias Hank.Core.Connection.Server, as: Connection

  def start_link(%State{} = state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_cast({:connected, conn}, state) do
    Connection.send(conn, "USER Hank 0 * :Hank")
    Connection.send(conn, "NICK Hank")
    Connection.send(conn, "PRIVMSG NickServ :IDENTIFY password")
    {:noreply, %State{state | connection: conn}}
  end
end
