defmodule Kitsune.Aws.RequestTest do
  use ExUnit.Case
  doctest Kitsune.Aws.Request
  alias Kitsune.Aws.Request, as: R

  @doc """
  Tests if a GET request is successful

  For this test to pass, you need to have an instance of ElasticMQ running
  """
  test "Get SQS Url" do
    url = "http://localhost:9324/?Action=GetQueueUrl&QueueName=default"

    data = R.request(url: url, aws: [region: "sa-east-1", access_key: "test", secret_key: "test", service: "sqs"])

    x = data["GetQueueUrlResponse"]["GetQueueUrlResult"]["QueueUrl"]
    assert x != nil
    assert x != ""
  end
end
