defmodule Hank.Connection.State do
  defstruct [
    socket:         nil,
    hostname:       nil,
    port:           6667,
    channels:       [],
    event_manager:  nil,
    nickname:       nil,
    realname:       nil,
  ]
end
