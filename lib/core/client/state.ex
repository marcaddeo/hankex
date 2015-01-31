defmodule Hank.Core.Client.State do
  @moduledoc """
  The state of the client
  """

  defstruct [
    connection:  nil,
    channels:    [],
    nickname:    nil,
    password:    nil,
    realname:    nil,
    hooks:       [],
    extra:       [],
  ]
end
