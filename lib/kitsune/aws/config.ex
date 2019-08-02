defmodule Kitsune.Aws.Config do
  def get_secret_key() do
    k = Application.get_env :kitsune_aws, :secret_key
    if k == nil, do: System.fetch_env("AWS_SECRET_ACCESS_KEY") |> elem(1), else: k
  end

  def get_access_key() do
    k = Application.get_env :kitsune_aws, :access_key
    if k == nil, do: System.fetch_env("AWS_ACCESS_KEY_ID") |> elem(1), else: k
  end

  def get_default_region() do
    k = Application.get_env :kitsune_aws, :default_region
    if k == nil, do: System.fetch_env("AWS_DEFAULT_REGION") |> elem(1), else: k
  end
end
