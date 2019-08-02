defmodule ExAwsTest do
  use ExUnit.Case
  doctest ExAws

  test "greets the world" do
    assert ExAws.hello() == :world
  end
end
