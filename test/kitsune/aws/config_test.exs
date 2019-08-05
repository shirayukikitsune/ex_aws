defmodule Kitsune.Aws.ConfigTest do
  use ExUnit.Case
  doctest Kitsune.Aws.Config
  alias Kitsune.Aws.Config

  @secret_key "TEST SECRET KEY"
  @access_key "TEST ACCESS KEY"
  @region "TEST REGION"

  test "should get values from config keys" do
    Application.put_env :kitsune_aws, :secret_key, @secret_key
    Application.put_env :kitsune_aws, :access_key, @access_key
    Application.put_env :kitsune_aws, :default_region, @region

    secret_key = Config.get_secret_key()
    access_key = Config.get_access_key()
    region = Config.get_default_region()

    assert secret_key == @secret_key
    assert access_key == @access_key
    assert region == @region
  end

  test "should get values from environment variables" do
    System.put_env [{"AWS_SECRET_ACCESS_KEY", @secret_key}, {"AWS_ACCESS_KEY_ID", @access_key}, {"AWS_DEFAULT_REGION", @region}]

    secret_key = Config.get_secret_key()
    access_key = Config.get_access_key()
    region = Config.get_default_region()

    assert secret_key == @secret_key
    assert access_key == @access_key
    assert region == @region
  end
end