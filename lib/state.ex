defmodule Hank.Connection.State do
  defstruct [
    pid:       nil,
    socket:    nil,
    client:    nil,
    hostname:  nil,
    port:      6667,
  ]
end

defmodule Hank.Client.State do
  defstruct [
    pid:         nil,
    connection:  nil,
    channels:    [],
    nickname:    nil,
    realname:    nil,
    hooks:       [],
  ]
end
