defmodule Kitsune.Aws do
  use Application

  def start(_type, _args) do
    children = [
      Kitsune.AwsSupervisor
    ]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
