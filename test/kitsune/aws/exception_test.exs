defmodule Kitsune.Aws.ExceptionTest do
  use ExUnit.Case
  doctest Kitsune.Aws.Exception
  alias Kitsune.Aws.Exception

  test "should not raise an exception when response is successful" do
    # We do not need to make the entire response tree, since AWS responds with "Error" in the first level of the object
    response = %{"GetQueueUrlResponse" => %{}}

    assert Exception.verify_response(response) == response
  end

  test "should raise a SdkException when response has an error" do
    response = %{"Error" => %{"Code" => "Test", "Type" => "Test", "Message" => "Test"}}

    assert_raise Kitsune.Aws.SdkException, fn -> Exception.verify_response(response) end
  end
end
