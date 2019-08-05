defmodule Kitsune.Aws.Config do
  def get_secret_key(), do: get_var :secret_key, "AWS_SECRET_ACCESS_KEY"

  def get_access_key(), do: get_var :access_key, "AWS_ACCESS_KEY_ID"

  def get_default_region(), do: get_var :default_region, "AWS_DEFAULT_REGION"

  defp get_var(key, env) do
    value = Application.get_env :kitsune_aws, key
    if value == nil do
      value = System.fetch_env(env)
      if value != :error, do: value |> elem(1), else: nil
    else
      value
    end
  end
end
