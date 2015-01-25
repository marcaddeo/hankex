defmodule Hank.Client do
  use GenServer
  alias Hank.Message
  alias Hank.Connection
  alias Hank.Client.State, as: Client

  def start_link(%Client{} = client) do
    GenServer.start_link(__MODULE__, client)
  end

  def init(%Client{} = client) do
    {:ok, %Client{client | pid: self}}
  end

  def handle_cast({:handshake, connection}, %Client{} = client) do
    client = %Client{client | connection: connection}
    run_hook(:handshake, nil, client)
    {:noreply, client}
  end

  def handle_cast({:raw, message}, %Client{} = client) do
    parse_reply({:raw, message}, client, nil)
    {:noreply, client}
  end

  def handle_cast(%Message{} = message, %Client{} = client) do
    run_hook(message.command, message, client)
    {:noreply, client}
  end

  defp run_hook(hook, message, %Client{} = client) do
    if Keyword.has_key?(client.hooks, hook) do
      for function <- Keyword.get_values(client.hooks, hook) do
        function.(message, client) |> parse_reply(client, hook)
      end
    end
  end

  defp parse_reply(:noreply, _, _), do: :noreply
  defp parse_reply(:remove_hook, _, _) do
    IO.puts("Not implemented")
  end

  defp parse_reply({:privmsg, target, message}, %Client{connection: connection}, _) do
    Connection.send_message(connection, "PRIVMSG #{target} :#{message}")
  end

  defp parse_reply({:raw, message}, %Client{connection: connection}, _) do
    Connection.send_message(connection, message)
  end

  defp parse_reply(collection, %Client{} = client, hook) do
    Enum.map(collection, fn (action) -> parse_reply(action, client, hook) end)
  end
end
