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
    Task.Supervisor.async(server, Kitsune.Request, :run, [{:get, uri, headers}])
  end

  def run({:get, uri, headers}) do
    u = URI.parse(uri)
    {:ok, conn} = Mint.HTTP.connect(String.to_atom(u.scheme), u.host, u.port)
    {:ok, conn, _ref} = Mint.HTTP.request(conn, "GET", get_request_path(u.path, u.query), headers)

    receive do
      message ->
        {:ok, conn, responses} = Mint.HTTP.stream(conn, message)
        {:ok, _r} = Mint.HTTP.close(conn)
        responses
    end
  end

  defp get_request_path(path, nil), do: path
  defp get_request_path(path, params), do: path <> "?" <> params
end
