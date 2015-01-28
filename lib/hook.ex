defmodule Hank.Hook do
  defmacro __using__(_) do
    quote do
      import Hank.Hook
      use GenServer
      alias Hank.Message

      def get_info(), do: {@tag, @version}
      def register(client) do
        {:ok, pid} = GenServer.start(__MODULE__, client)
        {:ok, @tag, pid}
      end
    end
  end
end
