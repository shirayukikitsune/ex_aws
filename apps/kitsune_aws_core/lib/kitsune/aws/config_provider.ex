defmodule Kitsune.Aws.ConfigProvider do
  @moduledoc """
  Behaviour of all AWS Configuration Providers
  """

  @callback load() :: Kitsune.Aws.Config.t()
end
