defmodule Hank.Core.Message do
  defstruct [
    prefix: nil,
    command: nil,
    target: nil,
    sender: nil,
    hostmask: nil,
    params: nil,
  ]
end
