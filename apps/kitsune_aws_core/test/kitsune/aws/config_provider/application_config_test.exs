defmodule Kitsune.Aws.ConfigProvider.ApplicationConfigTest do
  use ExUnit.Case, async: false
  doctest Kitsune.Aws.ConfigProvider.ApplicationConfig
  alias Kitsune.Aws.ConfigProvider.ApplicationConfig

  @secret_key "TEST SECRET KEY"
  @access_key "TEST ACCESS KEY"
  @region "TEST REGION"

  setup do
    Application.put_env :kitsune_aws, :secret_key, @secret_key
    Application.put_env :kitsune_aws, :access_key, @access_key
    Application.put_env :kitsune_aws, :default_region, @region
  end

  test "should return an instance of Kitsune.Aws.Config" do
    config = ApplicationConfig.load()

    assert config != nil
    assert config.__struct__ == Kitsune.Aws.Config
  end

  test "should get secret key" do
    config = ApplicationConfig.load()

    assert config.secret_key == @secret_key
  end

  test "should get access key" do
    config = ApplicationConfig.load()

    assert config.access_key == @access_key
  end

  test "should get default region" do
    config = ApplicationConfig.load()

    assert config.default_region == @region
  end
end
