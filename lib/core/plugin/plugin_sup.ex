defmodule Hank.Core.Plugin.Supervisor do
  use Supervisor
  require Logger
  alias Hank.Core.Message
  alias Hank.Core.Plugin.State, as: Plugin
  alias Hank.Core.Client.State, as: Client

  def start_link(plugins) do
    Logger.info("Starting Plugin Supervisor")
    Supervisor.start_link(__MODULE__, plugins, name: __MODULE__)
  end

  def init(plugins) do
    children = Enum.map(plugins, fn (%Plugin{module: module}) ->
      worker(module, [])
    end)

    supervise(children, strategy: :one_for_one)
  end

  def handle_message(%Message{command: command} = message, %Client{plugins: plugins} = client) do
    if Process.whereis(__MODULE__) do
      plugins = plugins
        |> Enum.map(fn (%Plugin{module: module, hooks: hooks}) ->
          if Enum.member?(hooks, command), do: module
        end)

      for {module, pid, _, _} <- Supervisor.which_children(__MODULE__) do
        if Enum.member?(plugins, module) do
          GenServer.cast(pid, {message, client})
        end
      end
    end
  end
end
