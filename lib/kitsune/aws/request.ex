defmodule Kitsune.Aws.Request do
  alias Kitsune.Request, as: R
  alias Kitsune.RequestSupervisor
  alias Kitsune.Aws.Canonical
  alias Kitsune.Aws.Config
  alias Kitsune.Aws.Signature

  def get(uri, service, headers \\ [], opts \\ %{}) do
    region = opts["region"] || Config.get_default_region() || raise "Region not set for request"
    secret_access_key = opts["secret_key"] || Config.get_secret_key() || raise "AWS Secret Access Key not defined. Please set :kitsune_aws properly or the environment variable AWS_SECRET_ACCESS_KEY"
    access_key_id = opts["access_key"] || Config.get_access_key() || raise "AWS Access Key ID not defined. Please set :kitsune_aws properly or the environment variable AWS_ACCESS_KEY_ID"

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    headers = headers ++ [{"x-amz-date", DateTime.to_iso8601(now, :basic)}]
    headers_with_host = headers ++ [{"host", URI.parse(uri).host}]

    credential_scope = Signature.get_credential_scope(now, region, service)
    signed_headers = Canonical.get_signed_headers(headers_with_host)
    canonical_request_hash = Canonical.get_canonical_request("GET", uri, headers_with_host, "")
                             |> Canonical.get_hash()
    string_to_sign = Signature.get_string_to_sign(now, credential_scope, canonical_request_hash)
    signing_key = Signature.get_signing_key(secret_access_key, region, service, now |> DateTime.to_date)
    signature = Signature.sign(signing_key, string_to_sign) |> Base.encode16 |> String.downcase

    authorization_header = "AWS4-HMAC-SHA256 Credential=#{access_key_id}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"

    headers = headers ++ [{"authorization", authorization_header}]

    R.get(RequestSupervisor, uri, headers)
  end
end
