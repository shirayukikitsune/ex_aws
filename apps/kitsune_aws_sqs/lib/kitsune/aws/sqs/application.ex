defmodule Kitsune.Aws.Sqs.Application do
  @moduledoc """
  This application will start the required supervisors in order to make requests to SQS endpoints
  """

  use Application

  def start(_type, _args) do
    children = [
      { Task.Supervisor, name: Kitsune.Aws.Sqs.RequestSupervisor }
    ]

    opts = [strategy: :one_for_one, name: Kitsune.Aws.Sqs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
