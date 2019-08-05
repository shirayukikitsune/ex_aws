defmodule Kitsune.Aws.Sqs do
  alias Kitsune.Aws.Canonical
  alias Kitsune.Aws.Request

  @service_name "sqs"
  @accept_json {"accept", "application/json"}

  def get_queue_url(opts) do
    region = opts["region"]
    queue_name = Canonical.uri_encode opts["name"]
    url = "https://sqs.#{region}.amazonaws.com/?Action=GetQueueUrl&QueueName=#{queue_name}"

    data = Request.get(url, @service_name, [@accept_json], opts)
      |> Task.await
      |> Enum.find(fn x -> elem(x, 0) == :data end)
      |> elem(2)
      |> Poison.decode!

    data["GetQueueUrlResponse"]["GetQueueUrlResult"]["QueueUrl"]
  end
end
