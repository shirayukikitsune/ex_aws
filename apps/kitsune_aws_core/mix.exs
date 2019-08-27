defmodule Kitsune.Aws.Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :kitsune_aws_core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mojito, "~> 0.5.0"},
      {:poison, "~> 4.0.1"}
    ]
  end
end
