defmodule Hank.Connection.ConnectionServer do
  use GenServer
  alias Hank.Connection.State
  alias Hank.Parser

  @supervisor Hank.Connection.ConnectionSupervisor

  def start_link(%State{} = state) do
    IO.puts "Starting ConnectionServer"
    GenServer.start_link(__MODULE__, state)
  end

  def init(%State{hostname: hostname, port: port} = state) do
    {:ok, socket} = Socket.TCP.connect(hostname, port, packet: :line)
    {:ok, %State{state | socket: socket}, 0}
  end

  def handle_info(:timeout, %State{} = state) do
    GenServer.cast(@supervisor.get_client(), :connected)
    {:noreply, state}
  end

  def handle_call(:socket, _, %State{socket: socket} = state) do
    {:reply, socket, state}
  end

  def handle_cast({:receive, data}, %State{} = state) do
    message = Parser.parse(data)
    IO.puts data
    GenServer.cast(@supervisor.get_client(), message)
    {:noreply, state}
  end

  def handle_cast({:send, message}, %State{socket: socket} = state) do
    IO.puts "Sending #{message}"
    Socket.Stream.send!(socket, "#{message}\r\n")
    {:noreply, state}
  end
end
