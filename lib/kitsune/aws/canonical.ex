defmodule Kitsune.Aws.Canonical do
  def should_encode_param(ch), do: (ch >= ?A && ch <= ?Z) || (ch >= ?a && ch <= ?z) || (ch >= ?0 && ch <= ?9) || ch == ?_ || ch == ?- || ch == ?~ || ch == ?.
  def should_encode(ch), do: should_encode_param(ch) || ch == ?/
  @doc """
  Encodes a string for URIs, using `should_encode/1` as encoder
  """
  def uri_encode(string), do: URI.encode(string, &should_encode/1)
  def param_encode(string), do: URI.encode(string, &should_encode_param/1)
  def get_canonical_method(method), do: String.upcase method

  def get_canonical_uri(uri), do: uri_encode(URI.parse(uri).path || "/")

  def get_canonical_query_string(uri) do
    (URI.parse(uri).query || "")
    |> URI.decode_query
    |> Enum.to_list
    |> Enum.map_join("&", fn {k,v} -> param_encode(to_string(k)) <> "=" <> param_encode(to_string(v)) end)
  end

  def get_canonical_headers(headers) do
    headers
    |> Enum.map_join("\n", fn {k, v} -> String.downcase(k) <> ":" <> String.trim(v) end)
  end

  def get_signed_headers(headers) do
    headers
    |> Enum.map(fn {k, _v} -> String.downcase(k) end)
    |> Enum.join(";")
  end

  def get_hash(payload), do: :crypto.hash(:sha256, payload) |> Base.encode16 |> String.downcase

  def get_canonical_request(method, uri, headers, payload) do
    headers_with_host = (headers ++ [{"host", URI.parse(uri).host}])
      |> Enum.sort_by(fn {k, _v} -> String.downcase(k) end)
      |> Enum.dedup_by(fn {k, _v} -> String.downcase(k) end)
    get_canonical_method(method) <> "\n" <>
    get_canonical_uri(uri) <> "\n" <>
    get_canonical_query_string(uri) <> "\n" <>
    get_canonical_headers(headers_with_host) <> "\n\n" <>
    get_signed_headers(headers_with_host) <> "\n" <>
    get_hash(payload)
  end
end
