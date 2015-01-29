defmodule Hank.Connection.State do
  defstruct [
    socket:    nil,
    hostname:  nil,
    port:      6667,
  ]
end
