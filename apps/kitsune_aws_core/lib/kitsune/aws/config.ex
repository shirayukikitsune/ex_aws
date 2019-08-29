defmodule Kitsune.Aws.Config do
  @moduledoc """
  This module is used to load the default credentials from one or many [Configuration Providers](configuration-providers.html)

  The credentials are internally stored in a table in the [Erlang Term Storage](http://www.erlang.org/doc/man/ets.html).
  Since the ETS for `:set` tables can insert and lookup in constant time, all operations in this module will also run in
  constant time.
  """

  defstruct [:access_key, :secret_key, :default_region]

  @typedoc """
  The struct that should be returned by every single [Configuration Provider](configuration-providers.html)
  """
  @type t() :: %Kitsune.Aws.Config{access_key: String.t(), secret_key: String.t(), default_region: String.t()}

  @doc """
  Loads configuration from the specified providers

  If no providers are specified (i.e., `providers == nil`), then `get_default_providers/0` is used instead.

  This function returns the loaded configuration. In case of error, `nil` will be returned instead.
  """
  @spec load([]) :: Kitsune.Aws.Config.t(), nil
  def load(providers \\ nil) do
    providers = providers || get_default_providers()
    config = try do
      Stream.map(providers, &load_provider/1)
      |> Stream.filter(fn config -> config != nil end)
      |> Enum.reduce(%Kitsune.Aws.Config{}, fn config, acc -> Map.merge(acc, config) end)
    rescue
      Enum.EmptyError -> nil
    end

    save(config)
  end

  @doc """
  Returns the list of the default configuration providers

  This function will always return the following list:

      [Kitsune.Aws.ConfigProvider.ApplicationConfig, Kitsune.Aws.ConfigProvider.Environment]
  """
  def get_default_providers(), do: [Kitsune.Aws.ConfigProvider.ApplicationConfig, Kitsune.Aws.ConfigProvider.Environment]

  @doc """
  Returns the AWS Access Key ID

  If the configuration was not loaded or the access key ID was not provided in them, `nil` shall be returned.
  """
  @spec get_access_key() :: String.t(), nil
  def get_access_key(), do: get_var(:access_key)

  @doc """
  Returns the AWS Secret Access Key

  If the configuration was not loaded or the secret access key was not provided in them, `nil` shall be returned.
  """
  @spec get_secret_key() :: String.t(), nil
  def get_secret_key(), do: get_var(:secret_key)

  @doc """
  Returns the default AWS region

  If the configuration was not loaded or the region was not provided in them, `nil` shall be returned.
  """
  @spec get_default_region() :: String.t(), nil
  def get_default_region(), do: get_var(:default_region)

  defp get_var(var) do
    try do
      case :ets.lookup(:kitsune_aws_config, var) do
        [{^var, value}] -> value
        _ -> nil
      end
    rescue
      _ -> nil
    end
  end

  defp save(config) do
    if :ets.whereis(:kitsune_aws_config) == :undefined do
      :ets.new :kitsune_aws_config, [:named_table]
    end

    :ets.insert :kitsune_aws_config,
                secret_key: config.secret_key,
                access_key: config.access_key,
                default_region: config.default_region

    config
  end

  defp load_provider(provider) do
    try do
      apply(provider, :load, [])
    rescue
      _ -> nil
    end
  end
end
