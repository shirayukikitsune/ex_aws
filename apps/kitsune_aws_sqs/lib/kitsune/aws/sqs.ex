defmodule Kitsune.Aws.Sqs do
  alias Kitsune.Aws.Canonical
  alias Kitsune.Aws.Request

  @service_name "sqs"

  def get_queue_url(opts) do
    url = get_queue_url_param opts[:url], opts
    queue_name = Canonical.uri_encode opts[:name]
    {_, new_opts} = Access.pop(opts, :name)
    {_, new_opts} = Access.pop(new_opts, :raw)

    data = Request.request(url: url, aws: [service: @service_name] ++ new_opts, query: [{"Action", "GetQueueUrl"}, {"QueueName", queue_name}])
    if opts[:raw] == true, do: data, else: data["GetQueueUrlResponse"]["GetQueueUrlResult"]["QueueUrl"]
  end

  def send_message(body, opts) do
    queue_url = opts[:url]
    params = Enum.concat [
      [{"Action","SendMessage"}],
      get_param("DelaySeconds", opts[:delay]),
      (if opts[:attributes], do: extract_send_attributes_params(opts[:attributes]), else: []),
      get_param("MessageDeduplicationId", opts[:dedup]),
      get_param("MessageGroupId", opts[:group]),
      get_param("MessageBody", Canonical.param_encode(body))
    ]

    data = Request.request(url: queue_url, aws: [service: @service_name] ++ opts, query: params)
    if opts[:raw] == true, do: data, else: data["SendMessageResponse"]["SendMessageResult"]
  end

  def receive_message(opts) do
    queue_url = opts[:url]
    params = Enum.concat [
      [{"Action","ReceiveMessage"}],
      (if opts[:attributes], do: extract_attributes_params(opts[:attributes]), else: []),
      get_param("MaxNumberOfMessages", opts[:message_count]),
      get_param("ReceiveRequestAttemptId", opts[:receive_request_attempt_id]),
      get_param("VisibilityTimeout", opts[:visibility_timeout]),
      get_param("WaitTimeSeconds", opts[:wait_time])
    ]

    data = Request.request(url: queue_url, aws: [service: @service_name] ++ opts, query: params)
    if opts[:raw] == true, do: data, else: data["ReceiveMessageResponse"]["ReceiveMessageResult"]
  end

  def delete_message(receipt_handle, opts) do
    queue_url = opts[:url]
    params = [{"Action", "DeleteMessage"}, {"ReceiptHandle", Canonical.param_encode(receipt_handle)}]

    data = Request.request(url: queue_url, aws: [service: @service_name] ++ opts, query: params)
    if opts[:raw] == true, do: data, else: data["DeleteMessageResponse"]
  end

  defp get_queue_url_param(nil, opts) do
    region = opts[:region] || Kitsune.Aws.Config.get_default_region()
    "https://sqs.#{region}.amazonaws.com/"
  end
  defp get_queue_url_param(url, _), do: url

  defp get_param(param, opt) do
    if opt, do: [{param, to_string(opt)}], else: []
  end

  defp extract_attributes_params(attributes) do
    Enum.with_index(attributes)
      |> Enum.map(fn {attr, i} -> {"AttributeName.#{i}", Canonical.param_encode(attr)} end)
  end

  defp extract_send_attributes_params(attributes) do
    Enum.with_index(attributes)
      |> Enum.flat_map(fn {attr, i} ->
          [
            {"MessageAttribute.#{i}.Name", Canonical.param_encode(attr[:name])},
            {"MessageAttribute.#{i}.Value.DataType", "String"},
            {"MessageAttribute.#{i}.Value.StringValue", Canonical.param_encode(to_string(attr[:value]))}
          ]
        end)
  end
end
