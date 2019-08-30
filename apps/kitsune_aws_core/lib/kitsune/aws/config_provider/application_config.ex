defmodule Kitsune.Aws.ConfigProvider.ApplicationConfig do
  @moduledoc """
  This implements the configuration loader from application configuration (i.e. `Config`)

  All configuration should be done in the :kitsune_aws key.

  ## Examples:

      import Config

      config :kitsune_aws,
        secret_key: "MY AWS SECRET KEY",
        access_key: "MY AWS ACCESS KEY",
        default_region: "us-east-1"

  """

  @behaviour Kitsune.Aws.ConfigProvider

  @doc """
  Populates the `Kitsune.Aws.Config` struct with values from application configuration
  """
  @spec load() :: Kitsune.Aws.Config.t()
  def load() do
    access_key = get_access_key()
    secret_key = get_secret_key()
    region = get_default_region()

    case {access_key,secret_key,region} do
      {nil,nil,nil} -> nil
      _ -> %Kitsune.Aws.Config{
             access_key: access_key,
             secret_key: secret_key,
             default_region: region
           }
    end
  end

  defp get_secret_key(), do: Application.get_env(:kitsune_aws, :secret_key)
  defp get_access_key(), do: Application.get_env(:kitsune_aws, :access_key)
  defp get_default_region(), do: Application.get_env(:kitsune_aws, :default_region)
end
