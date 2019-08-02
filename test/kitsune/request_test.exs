defmodule Kitsune.RequestTest do
  use ExUnit.Case, async: true
  alias Kitsune.Request
  require Poison

  setup do
    start_supervised!({Task.Supervisor, name: TestTaskSupervisor})
    :ok
  end

  test "GET request should work" do
    r = Request.get(TestTaskSupervisor, "https://postman-echo.com/get?foo1=bar1&foo2=bar2")
    |> Task.await
    |> Enum.find(fn x -> elem(x, 0) == :data end) |> elem(2) |> Poison.decode!

    assert r["url"] == "https://postman-echo.com/get?foo1=bar1&foo2=bar2"
  end
end
