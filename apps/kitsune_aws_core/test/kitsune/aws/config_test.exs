defmodule Kitsune.Aws.ConfigTest do
  use ExUnit.Case, async: false
  doctest Kitsune.Aws.Config
  alias Kitsune.Aws.Config

  defmodule NullConfigProvider do
    def load(), do: nil
  end
  defmodule MockConfigProvider do
    def load() do
      %Kitsune.Aws.Config{
        secret_key: "mock",
        access_key: "mock",
        default_region: "mock"
      }
    end
  end

  describe "load/1" do
    test "should load configuration from a provider" do
      config = Config.load([MockConfigProvider])

      assert config != nil
      assert config.secret_key == "mock"
    end

    test "should load configuration from the first available provider" do
      config = Config.load([NullConfigProvider, MockConfigProvider])

      assert config != nil
      assert config.secret_key == "mock"
    end

    test "ApplicationConfig default provider" do
      Application.put_env :kitsune_aws, :secret_key, "test"
      Application.put_env :kitsune_aws, :access_key, "test"
      Application.put_env :kitsune_aws, :default_region, "test"

      config = Config.load()

      assert config != nil
      assert config.secret_key == "test"

      Application.delete_env :kitsune_aws, :secret_key
      Application.delete_env :kitsune_aws, :access_key
      Application.delete_env :kitsune_aws, :default_region
    end

    test "Environment default provider" do
      System.put_env [{"AWS_SECRET_ACCESS_KEY", "test2"}, {"AWS_ACCESS_KEY_ID", "test2"}, {"AWS_DEFAULT_REGION", "test2"}]

      config = Config.load()

      assert config != nil
      assert config.secret_key == "test2"

      System.delete_env "AWS_SECRET_ACCESS_KEY"
      System.delete_env "AWS_ACCESS_KEY_ID"
      System.delete_env "AWS_DEFAULT_REGION"
    end

    test "Environment should take precedence over ApplicationConfig" do
      Application.put_env :kitsune_aws, :secret_key, "test"
      Application.put_env :kitsune_aws, :access_key, "test"
      Application.put_env :kitsune_aws, :default_region, "test"
      System.put_env [{"AWS_SECRET_ACCESS_KEY", "test2"}, {"AWS_ACCESS_KEY_ID", "test2"}, {"AWS_DEFAULT_REGION", "test2"}]

      config = Config.load()

      assert config != nil
      assert config.secret_key == "test2"
    end
  end
end
