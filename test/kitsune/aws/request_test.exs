defmodule Kitsune.Aws.RequestTest do
  use ExUnit.Case
  doctest Kitsune.Aws.Request
  alias Kitsune.Aws.Request, as: R

  setup do
    start_supervised!({Task.Supervisor, name: Kitsune.RequestSupervisor})
    :ok
  end

  test "Get SQS Url" do
    url = "https://sqs.sa-east-1.amazonaws.com/?Action=GetQueueUrl&QueueName=some-queue.fifo"

    data = R.get(url, "sqs", [{"accept", "application/json"}])
           |> Task.await
           |> Enum.find(fn x -> elem(x, 0) == :data end)
           |> elem(2)
           |> Poison.decode!

    x = data["GetQueueUrlResponse"]["GetQueueUrlResult"]["QueueUrl"]
    assert x != nil
    assert x != ""
  end
end
