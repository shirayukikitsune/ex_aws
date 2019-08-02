defmodule Kitsune.Aws.RequestTest do
  use ExUnit.Case, async: true
  alias Kitsune.Aws.Request

  setup %{test: test} do
    request = start_supervised!(Request)
    %{request: request}
  end

  test "works", %{request: request} do
    r = GenServer.call(request, {:get, "https://www.google.com/", []})
    IO.inspect(r)
  end
end
