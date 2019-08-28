defmodule Kitsune.Aws.ConfigProvider.Environment do
  @moduledoc """
  This implements the configuration loader from environment variables

  The variables used are:

  - `AWS_SECRET_ACCESS_KEY`: the AWS Secret Access Key
  - `AWS_ACCESS_KEY_ID`: the AWS Access Key ID
  - `AWS_DEFAULT_REGION`: the default AWS region

  """

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

  defp get_secret_key(), do: System.get_env("AWS_SECRET_ACCESS_KEY")
  defp get_access_key(), do: System.get_env("AWS_ACCESS_KEY_ID")
  defp get_default_region(), do: System.get_env("AWS_DEFAULT_REGION")
end
