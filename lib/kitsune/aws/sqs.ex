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
      |> Request.await

    data["GetQueueUrlResponse"]["GetQueueUrlResult"]["QueueUrl"]
  end

  def receive_message(opts) do
    queue_url = opts["url"]
    params = [{"Action","ReceiveMessage"}]
    params = params ++ if opts["attributes"], do: extract_attributes_params(opts["attributes"]), else: []
    params = params ++ get_param("MaxNumberOfMessages", opts["message_count"])
    params = params ++ get_param("ReceiveRequestAttemptId", opts["receive_request_attempt_id"])
    params = params ++ get_param("VisibilityTimeout", opts["visibility_timeout"])
    params = params ++ get_param("WaitTimeSeconds", opts["wait_time"])
    params_str = Enum.to_list(params) |> Enum.map_join("&", &map_param/1)
    url = if params_str != "", do: "#{queue_url}?#{params_str}", else: queue_url

    data = Request.get(url, @service_name, [@accept_json], opts)
      |> Request.await

    data["ReceiveMessageResponse"]["ReceiveMessageResult"]
  end

  defp map_param(param), do: elem(param, 0) <> "=" <> elem(param, 1)

  defp get_param(param, opt) do
    if opt, do: {param, to_string(opt)}, else: []
  end

  defp extract_attributes_params(attributes) do
    Enum.with_index(attributes)
      |> Enum.map(fn {attr, i} -> {"AttributeName.#{i}", attr} end)
  end
end
