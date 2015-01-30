defmodule Hank do
  use Application
  use Hank.Commands

  def start(_, _) do
    Hank.Supervisor.start_link()
  end
end
