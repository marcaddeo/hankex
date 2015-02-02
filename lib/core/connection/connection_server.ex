defmodule Hank.Core.Connection.Server do
  use GenServer
  require Logger
  alias Hank.Core.Connection.State
  alias Hank.Core.Connection.SocketAgent
  alias Hank.Core.Client.Server, as: Client

  ############
  # Public API
  ############
  def send(message), do: GenServer.cast(__MODULE__, {:send, message})
  def receive(data), do: GenServer.cast(__MODULE__, {:receive, data})

  ###############
  # GenServer API
  ###############
  def start_link(%State{} = state) do
    Logger.info("Starting Connection Server")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(%State{hostname: hostname, port: port} = state) do
    {:ok, socket} = Socket.TCP.connect(hostname, port, packet: :line)
    SocketAgent.set_socket(socket)
    {:ok, %State{state | socket: socket}, 0}
  end

  def handle_info(:timeout, %State{} = state) do
    Client.connect()
    {:noreply, state}
  end

  def handle_cast({:receive, data}, %State{} = state) do
    Client.receive(data)
    {:noreply, state}
  end

  def handle_cast({:send, message}, %State{socket: socket} = state) do
    IO.puts "Sending #{message}"
    Socket.Stream.send!(socket, "#{message}\r\n")
    {:noreply, state}
  end

  def termindate(_, _) do
    SocketAgent.clear_socket()
    :ok
  end
end
