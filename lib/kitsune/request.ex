defmodule Kitsune.Request do
  use Task

  @doc """
  Starts the request
  """
  def start_link(opts) do
    Task.start_link(__MODULE__, :run, [opts])
  end

  @doc """
  Perform a GET request
  """
  def get(server, uri, headers \\ []) do
    Task.Supervisor.async(server, Kitsune.Request, :run, [{:get, uri, nil, headers}])
  end

  @doc """
  Perform a POST request
  """
  def post(server, uri, body, headers \\ []) do
    Task.Supervisor.async(server, Kitsune.Request, :run, [{:post, uri, body, headers}])
  end

  def run({:get, uri, _body, headers}) do
    u = URI.parse(uri)
    {:ok, conn} = Mint.HTTP.connect(String.to_atom(u.scheme), u.host, u.port)
    {:ok, conn, _ref} = Mint.HTTP.request(conn, "GET", get_request_path(u.path, u.query), headers, nil)

    {conn, response} = get_response conn
    Mint.HTTP.close(conn)
    response
  end

  def run({:post, uri, body, headers}) do
    u = URI.parse(uri)
    {:ok, conn} = Mint.HTTP.connect(String.to_atom(u.scheme), u.host, u.port)
    {:ok, conn, _ref} = Mint.HTTP.request(conn, "POST", get_request_path(u.path, u.query), headers, body)

    {conn, response} = get_response conn
    Mint.HTTP.close(conn)
    response
  end

  defp get_response(conn, responses \\ []) do
    receive do
      message ->
        {:ok, conn, r} = Mint.HTTP.stream(conn, message)
        r = Enum.concat(responses, r)
        if is_done(r), do: {conn, r}, else: get_response(conn, r)
    end
  end

  defp is_done(responses) do
    Enum.find(responses, fn r -> elem(r, 0) == :done end) != nil
  end

  defp get_request_path(nil, nil), do: "/"
  defp get_request_path(nil, params), do: "/?" <> params
  defp get_request_path(path, nil), do: path
  defp get_request_path(path, params), do: path <> "?" <> params
end
