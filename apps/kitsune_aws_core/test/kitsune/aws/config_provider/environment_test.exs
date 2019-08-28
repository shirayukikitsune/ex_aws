defmodule Kitsune.Aws.ConfigProvider.EnvironmentTest do
  use ExUnit.Case, async: false
  doctest Kitsune.Aws.ConfigProvider.Environment
  alias Kitsune.Aws.ConfigProvider.Environment

  @secret_key "TEST SECRET KEY"
  @access_key "TEST ACCESS KEY"
  @region "TEST REGION"

  setup do
    System.put_env "AWS_SECRET_ACCESS_KEY", @secret_key
    System.put_env "AWS_ACCESS_KEY_ID", @access_key
    System.put_env "AWS_DEFAULT_REGION", @region
  end

  test "should return an instance of Kitsune.Aws.Config" do
    config = Environment.load()

    assert config != nil
    assert config.__struct__ == Kitsune.Aws.Config
  end

  test "should get secret key" do
    config = Environment.load()

    assert config.secret_key == @secret_key
  end

  test "should get access key" do
    config = Environment.load()

    assert config.access_key == @access_key
  end

  test "should get default region" do
    config = Environment.load()

    assert config.default_region == @region
  end
end
