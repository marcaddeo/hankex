defmodule Hank.Core.Connection.State do
  defstruct [
    socket:    nil,
    hostname:  nil,
    port:      6667,
  ]
end
