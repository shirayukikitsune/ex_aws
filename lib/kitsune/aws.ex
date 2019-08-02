defmodule Kitsune.Aws do
  @moduledoc false

  use Supervisor

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, :ok, init_args)
  end

  def init(:ok) do
    children = [
      { Task.Supervisor, name: Kitsune.RequestSupervisor }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end

