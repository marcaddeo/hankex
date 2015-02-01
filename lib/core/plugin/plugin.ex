defmodule Hank.Core.Plugin do
  defmacro __using__(_) do
    quote do
      import Hank.Core.Plugin
      use GenServer
      alias Hank.Core.Message

      def start_link() do
        GenServer.start_link(__MODULE__, [])
      end
    end
  end
end
