defmodule Kitsune.Aws.SqsTest do
  use ExUnit.Case
  doctest Kitsune.Aws.Sqs
  alias Kitsune.Aws.Sqs

  @secret_key "TEST SECRET KEY"
  @access_key "TEST ACCESS KEY"
  @region "TEST REGION"

  setup_all do
    Application.put_env :kitsune_aws, :secret_key, @secret_key
    Application.put_env :kitsune_aws, :access_key, @access_key
    Application.put_env :kitsune_aws, :default_region, @region
    {:ok, %{}}
  end

  describe "get_queue_url/1" do
    test "should get queue url successfully for existing queues" do
      queue_url = Sqs.get_queue_url name: "default", url: "http://localhost:9324/"

      assert queue_url != nil
    end

    test "should return nil for non-existing queue" do
      url = Sqs.get_queue_url name: "invalid", url: "http://localhost:9324/"

      assert url == nil
    end
  end

  describe "send_message/1" do
    setup do
      queue_url = Sqs.get_queue_url name: "default", url: "http://localhost:9324/"
      {:ok, queue_url: queue_url}
    end

    test "should successfully send a message with attributes", ctx do
      queue_url = ctx[:queue_url]
      response = Sqs.send_message "test message", url: queue_url, attributes: [[name: "test attribute", value: "test value"]]

      assert response["MessageId"] != nil
    end
  end

  describe "receive_message/1" do
    setup do
      queue_url = Sqs.get_queue_url name: "default", url: "http://localhost:9324/"
      {:ok, queue_url: queue_url}
    end

    test "should successfully receive a message with attributes", ctx do
      queue_url = ctx[:queue_url]
      response = Sqs.receive_message url: queue_url, attributes: ["test attribute"]

      assert response != nil
    end
  end

  describe "delete_message/2" do
    setup do
      queue_url = Sqs.get_queue_url name: "default", url: "http://localhost:9324/"
      {:ok, queue_url: queue_url}
    end

    test "should delete a message from the queue", ctx do
      queue_url = ctx[:queue_url]
      response = Sqs.delete_message "00000000-0000-0000-0000-000000000000", url: queue_url

      assert response != nil
    end
  end
end
