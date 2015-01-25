defmodule Hank.Connection do
  use GenServer
  alias Hank.Connection.State
  alias Hank.Parser

  def start_link(event_manager, %State{} = state) do
    start_link(%State{state | event_manager: event_manager})
  end

  def start_link(%State{event_manager: event_manager} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(%State{} = state) do
    {:ok, socket} = Socket.TCP.connect(state.hostname, state.port, packet: :line)
    {:ok, %State{state | socket: socket}, 0}
  end

  def handle_info(:timeout, state) do
    GenEvent.sync_notify(state.event_manager, {:init, state})
    listen(state)
    {:noreply, state}
  end

  def listen(%State{socket: socket} = state) do
    case Socket.Stream.recv!(socket) do
      data when is_binary(data) ->
        message = Parser.parse(data)
        GenEvent.sync_notify(state.event_manager, {message, state})
        listen(state)
      nil ->
        :ok
    end
  end

  def send_message(%State{socket: socket} = state, message) do
    IO.puts "Sending #{message}"
    Socket.Stream.send!(socket, "#{message}\r\n")
  end
end
