defmodule Kitsune.Aws.Request do
  @moduledoc """
  This module is responsible for handling the common logic for HTTP requests to AWS
  """

  require Mojito

  alias Kitsune.Aws.Canonical
  alias Kitsune.Aws.Config
  alias Kitsune.Aws.Signature

  def request(request) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    uri = parse_url_with_query_parameters(request[:url], request[:query])

    headers = (request[:headers] || []) ++ [{"x-amz-date", DateTime.to_iso8601(now, :basic)}]

    authorization_header = get_authorization_header uri, headers, now, request[:aws]

    headers = headers ++ [{"authorization", authorization_header}]

    Mojito.request(method: request[:method] || :get,
                   headers: headers,
                   body: request[:body] || "",
                   opts: request[:opts] || [],
                   url: uri)
    |> handle_task_result
  end

  defp parse_url_with_query_parameters(url, params) do
    params_str = Enum.to_list(params || [])
                 |> Enum.map_join("&", &map_param/1)

    if params_str != "", do: "#{url}?#{params_str}", else: url
  end

  defp handle_task_result({:error, e}) do
    IO.inspect(e)
    raise Kitsune.Aws.SdkException, code: "RequestError", type: "request", description: "The request failed to complete"
  end
  defp handle_task_result({:ok, response}) do
    Kitsune.Aws.ResponseParser.parse_document(response.body)
    |> Kitsune.Aws.ResponseParser.parse_node
    |> Kitsune.Aws.Exception.verify_response
  end

  defp map_param({key, value}), do: "#{to_string(key)}=#{Canonical.param_encode(to_string(value))}"

  defp get_credentials(opts) do
    region = opts[:region] || Config.get_default_region() || raise "Region not set for request"
    secret_access_key = opts[:secret_key] || Config.get_secret_key() || raise "AWS Secret Access Key not defined. Please set :kitsune_aws properly or the environment variable AWS_SECRET_ACCESS_KEY"
    access_key_id = opts[:access_key] || Config.get_access_key() || raise "AWS Access Key ID not defined. Please set :kitsune_aws properly or the environment variable AWS_ACCESS_KEY_ID"

    { access_key_id, secret_access_key, region }
  end

  defp get_authorization_header(uri, headers, now, opts) do
    service = opts[:service]
    { access_key_id, secret_access_key, region } = get_credentials opts
    headers_with_host = headers ++ [{"host", URI.parse(uri).host}]

    credential_scope = Signature.get_credential_scope(now, region, service)
    signed_headers = Canonical.get_signed_headers(headers_with_host)
    canonical_request_hash = Canonical.get_canonical_request("GET", uri, headers_with_host, "")
                             |> Canonical.get_hash()
    string_to_sign = Signature.get_string_to_sign(now, credential_scope, canonical_request_hash)
    signing_key = Signature.get_signing_key(secret_access_key, region, service, now |> DateTime.to_date)
    signature = Signature.sign(signing_key, string_to_sign) |> Base.encode16 |> String.downcase

    "AWS4-HMAC-SHA256 Credential=#{access_key_id}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
  end
end
