defmodule Hank.Core.Message do
  defstruct [
    prefix: nil,
    command: nil,
    target: nil,
    sender: nil,
    hostmask: nil,
    params: nil,
    raw_params: nil,
  ]
end
