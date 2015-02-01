defmodule Hank.Core.Client.Server do
  use GenServer
  alias Hank.Core.Message
  alias Hank.Core.Client.State
  alias Hank.Core.Plugin.Supervisor, as: PluginSupervisor
  alias Hank.Core.Connection.Server, as: Connection

  @supervisor Hank.Core.Client.Supervisor

  def start_link(%State{} = state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_cast({:connected, conn}, state) do
    import Supervisor.Spec

    state = %State{state | connection: conn}
    Connection.send(conn, "USER Hank 0 * :Hank")
    Connection.send(conn, "NICK Hank")
    Connection.send(conn, "PRIVMSG NickServ :IDENTIFY password")
    Supervisor.start_child(@supervisor, supervisor(PluginSupervisor, [state]))
    {:noreply, state}
  end

  def handle_cast({:message, %Message{} = message}, state) do
    PluginSupervisor.handle_message(message, state)
    {:noreply, state}
  end

  def send_message(%State{connection: conn}, message), do: send_message(conn, message)
  def send_message(conn, message), do: Connection.send(conn, message)
end
