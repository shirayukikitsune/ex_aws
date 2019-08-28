defmodule Kitsune.Aws.Config do
  defstruct [:access_key, :secret_key, :default_region]

  def load(providers \\ [Kitsune.Aws.ConfigProvider.ApplicationConfig, Kitsune.Aws.ConfigProvider.Environment]) do
    config = try do
      Stream.map(providers, &load_provider/1)
      |> Stream.filter(fn config -> config != nil end)
      |> Enum.reduce(%Kitsune.Aws.Config{}, fn config, acc -> Map.merge(acc, config) end)
    rescue
      Enum.EmptyError -> nil
    end

    save(config)
  end

  def get_access_key(), do: get_var(:access_key)
  def get_secret_key(), do: get_var(:secret_key)
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
