defmodule Hank.Core.Connection.Server do
  use GenServer
  require Logger
  alias Hank.Core.Parser
  alias Hank.Core.Connection.State

  def start_link(%State{} = state) do
    Logger.info("Starting Connection Server")
    GenServer.start_link(__MODULE__, state)
  end

  def init(%State{hostname: hostname, port: port} = state) do
    {:ok, socket} = Socket.TCP.connect(hostname, port, packet: :line)
    {:ok, %State{state | socket: socket}, 0}
  end

  def handle_info(:timeout, %State{client: client} = state) do
    GenServer.cast(client, {:connected, self})
    {:noreply, state}
  end

  def handle_call(:socket, _, %State{socket: socket} = state),
  do: {:reply, socket, state}

  def handle_cast({:receive, data}, %State{client: client} = state) do
    IO.puts String.strip(data)
    GenServer.cast(client, {:message, Parser.parse(data)})
    {:noreply, state}
  end

  def handle_cast({:send, message}, %State{socket: socket} = state) do
    IO.puts "Sending #{message}"
    Socket.Stream.send!(socket, "#{message}\r\n")
    {:noreply, state}
  end

  def send(pid, message), do: GenServer.cast(pid, {:send, message})
end
