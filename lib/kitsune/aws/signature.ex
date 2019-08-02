defmodule Kitsune.Aws.Signature do
  def get_date_key(secret_access_key, date), do:
    :crypto.hmac(:sha256, "AWS4" <> secret_access_key, Date.to_iso8601(date, :basic))

  def get_region_key(date_key, region), do:
    :crypto.hmac(:sha256, date_key, region)

  def get_service_key(region_key, service), do:
    :crypto.hmac(:sha256, region_key, service)

  def get_signing_key(service_key), do:
    :crypto.hmac(:sha256, service_key, "aws4_request")

  def get_signing_key(secret_access_key, region, service, date) do
    get_date_key(secret_access_key, date)
    |> get_region_key(region)
    |> get_service_key(service)
    |> get_signing_key()
  end

  def get_credential_scope(date, region, service) do
    Date.to_iso8601(date, :basic) <> "/" <> region <> "/" <> service <> "/aws4_request"
  end

  def get_string_to_sign(date_time, credential_scope, canonical_request_hash) do
    "AWS4-HMAC-SHA256\n" <>
    DateTime.to_iso8601(date_time, :basic) <> "\n" <>
    credential_scope <> "\n" <>
    canonical_request_hash
  end
end
