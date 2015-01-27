defmodule Hank.Connection do
  use GenServer
  alias Hank.Connection.State
  alias Hank.Parser

  defmodule State do
    defstruct [
      socket:    nil,
      client:    nil,
      hostname:  nil,
      port:      6667,
    ]
  end

  def start_link(%State{} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(%State{} = state) do
    {:ok, socket} = Socket.TCP.connect(state.hostname, state.port, packet: :line)
    {:ok, %State{state | socket: socket}, 0}
  end

  def handle_info(:timeout, %State{client: client} = state) do
    GenServer.cast(client, {:handshake, state})
    listen(state)
    {:noreply, state}
  end

  def listen(%State{socket: socket, client: client} = state) do
    case Socket.Stream.recv!(socket) do
      data when is_binary(data) ->
        IO.puts data
        message = Parser.parse(data)
        GenServer.cast(client, message)
        listen(state)
      nil ->
        :ok
    end
  end

  def send_message(message, %State{socket: socket}) do
    IO.puts "Sending #{message}"
    Socket.Stream.send!(socket, "#{message}\r\n")
  end
end
