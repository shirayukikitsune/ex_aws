defmodule Kitsune.Aws.Request do
  use GenServer

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def handle_call({:get, uri, headers}, _from, state) do
    u = URI.parse(uri)
    {:ok, conn} = Mint.HTTP.connect(String.to_atom(u.scheme), u.host, u.port)
    {:ok, conn, _ref} = Mint.HTTP.request(conn, "GET", get_request_path(u.path, u.query), headers)

    receive do
      message ->
        {:ok, conn, responses} = Mint.HTTP.stream(conn, message)
        {:ok, _r} = Mint.HTTP.close(conn)
        {:reply, responses, state}
    end
  end

  defp get_request_path(path, nil), do: path
  defp get_request_path(path, params), do: path <> "?" <> params
end
