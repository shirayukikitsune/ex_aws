defmodule Kitsune.Aws.Canonical do
  @moduledoc """
  This module defines functions that are used to build the canonical request

  The canonical request is a string used to generate a signature of the request.

  It contains the following data, each one in its own line:

  1. The request method
  2. The request path
  3. The request query string
  4. The request headers (including the `Host` header)
  5. The headers that should be used to build the request signature
  6. The hash of the request payload (empty bodies should use the hash of an empty string)

  In this implementation, all headers that are sent to AWS are signed
  """

  @doc """
  Predicate for `URI.encode/2`

  Return true whenever a character should not be URI encoded

  For AWS parameters, this is true whenever a character matches the group [A-Za-z0-9_~.-]
  """
  @spec encode_param?(char()) :: boolean()
  def encode_param?(ch), do:
    (ch >= ?A && ch <= ?Z) || (ch >= ?a && ch <= ?z) ||
    (ch >= ?0 && ch <= ?9) ||
     ch == ?_ || ch == ?-  ||
     ch == ?~ || ch == ?.

  @doc """
  Predicate for `URI.encode/2`

  Return true whenever a character should not be URI encoded

  For AWS URIs, this is true whenever a character should not be param encoded (see `encode_param?/2`)
  or when it is the forward slash character (`/`)
  """
  @spec encode_uri?(char()) :: boolean()
  def encode_uri?(ch), do: encode_param?(ch) || ch == ?/

  @doc """
  Encodes a string for URIs, using `encode_uri?/1` as encoder
  """
  @spec uri_encode(String.t()) :: String.t()
  def uri_encode(string), do: URI.encode(string, &encode_uri?/1)

  @doc """
  Encodes a string for query parameters, using `encode_param?/1` as encoder
  """
  @spec param_encode(String.t()) :: String.t()
  def param_encode(string), do: URI.encode(string, &encode_param?/1)

  @doc """
  Returns the HTTP method in its canonical form: trimmed and all characters are uppercase

  ## Examples

      iex> Kitsune.Aws.Canonical.get_canonical_method(" get ")
      "GET"
      iex> Kitsune.Aws.Canonical.get_canonical_method("POST")
      "POST"

  """
  @spec get_canonical_method(String.t()) :: String.t()
  def get_canonical_method(method), do: String.trim String.upcase method

  @doc """
  Returns the canonical path for the given URI

  The canonical path is:
  - A forward slash (`/`) for empty paths (like `http://google.com`, for example)
  - URI encoded (see `uri_encode/1`)

  ## Examples

      iex> Kitsune.Aws.Canonical.get_canonical_path("http://www.google.com")
      "/"
      iex> Kitsune.Aws.Canonical.get_canonical_path("http://www.google.com?foo=bar")
      "/"
      iex> Kitsune.Aws.Canonical.get_canonical_path("http://www.google.com/foo/bar")
      "/foo/bar"

  """
  @spec get_canonical_path(String.t()) :: String.t()
  def get_canonical_path(uri), do: uri_encode(URI.parse(uri).path || "/")

  @doc """
  Returns the canonical query string for the given URI

  The query string has the following properties:
  - All parameters are sorted alphabetically ascending by its key
  - Both keys and values are encoded using `param_encode/1`

  ## Examples

      iex> Kitsune.Aws.Canonical.get_canonical_query_string("http://www.google.com")
      ""
      iex> Kitsune.Aws.Canonical.get_canonical_query_string("http://www.google.com?foo!=bar@")
      "foo%21=bar%40"
      iex> Kitsune.Aws.Canonical.get_canonical_query_string("http://www.google.com?foo!=bar@&baz=123")
      "baz=123&foo%21=bar%40"

  """
  @spec get_canonical_query_string(String.t()) :: String.t()
  def get_canonical_query_string(uri) do
    (URI.parse(uri).query || "")
    |> URI.decode_query
    |> Enum.to_list
    |> Enum.map_join("&", fn {k,v} -> param_encode(to_string(k)) <> "=" <> param_encode(to_string(v)) end)
  end

  @doc ~S"""
  Returns the canonical headers string

  The returned string has the following characteristics:
  - Every header is in its own line
  - If no headers are passed, a string containing the new line character is returned
  - Header keys are all lowercase
  - Values are trimmed

  ## Examples

      iex> Kitsune.Aws.Canonical.get_canonical_headers([])
      "\n"
      iex> Kitsune.Aws.Canonical.get_canonical_headers([{"Content-type", "application/json"}, {"Accept", " application/json"}])
      "accept:application/json\ncontent-type:application/json\n"

  """
  @spec get_canonical_headers([{String.t(),String.t()}]) :: String.t()
  def get_canonical_headers(headers) do
    Stream.map(headers, fn {k, v} -> {String.downcase(k), v} end)
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> get_canonical_headers_unsorted()
  end

  defp get_canonical_headers_unsorted(headers) do
    Enum.map_join(headers, "\n", fn {k, v} -> k <> ":" <> String.trim(to_string(v)) end) <> "\n"
  end

  @doc """
  Returns the headers that should be used for signing

  This is a semicolon separated list of all headers keys, in lowercase, that should be used to sign the request

  ## Examples

      iex> Kitsune.Aws.Canonical.get_signed_headers([])
      ""
      iex> Kitsune.Aws.Canonical.get_signed_headers([{"Content-type", "application/json"}, {"Accept", " application/json"}])
      "accept;content-type"
  """
  @spec get_signed_headers([{String.t(),String.t()}]) :: String.t()
  def get_signed_headers(headers) do
    Stream.map(headers, fn {k, v} -> {String.downcase(k), v} end)
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> get_signed_headers_unsorted()
  end

  defp get_signed_headers_unsorted(headers) do
    Enum.map_join(headers, ";", fn {k, _v} -> k end)
  end

  @doc """
  Hashes the request payload for the canonical request

  This returns the SHA2-256 hash of the payload, in a lower case hex string
  """
  @spec get_hash(String.t()) :: String.t()
  def get_hash(payload), do: :crypto.hash(:sha256, payload) |> Base.encode16 |> String.downcase

  @doc ~S"""
  Builds the canonical request string from the given request parameters

  This is a convenience function and the preferred way to build the canonical request string, since it avoids sorting
  twice the headers that would happen when using the `get_canonical_headers/1` and `get_signed_headers/1` directly.

  ## Example

      iex> Kitsune.Aws.Canonical.get_canonical_request("GET", "http://examplebucket.s3.amazonaws.com/test.txt", [], "")
      "GET\n/test.txt\n\nhost:examplebucket.s3.amazonaws.com\n\nhost\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  """
  @spec get_canonical_request(String.t(),String.t(),[{String.t(),String.t()}],String.t()) :: String.t()
  def get_canonical_request(method, uri, headers, payload) do
    headers_with_host = (headers ++ [{"host", URI.parse(uri).host}])
      |> Stream.map(fn {k, v} -> {String.downcase(k), v} end)
      |> Enum.sort_by(fn {k, _v} -> k end)
      |> Enum.dedup_by(fn {k, _v} -> k end)
    get_canonical_method(method) <> "\n" <>
    get_canonical_path(uri) <> "\n" <>
    get_canonical_query_string(uri) <> "\n" <>
    get_canonical_headers_unsorted(headers_with_host) <> "\n" <>
    get_signed_headers_unsorted(headers_with_host) <> "\n" <>
    get_hash(payload)
  end
end
