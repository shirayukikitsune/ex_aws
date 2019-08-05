defmodule KitsuneAws.MixProject do
  use Mix.Project

  def project do
    [
      app: :kitsune_aws,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Kitsune.Aws, []},
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:castore, "~> 0.1.0"},
      {:mint, "~> 0.2.0"},
      {:poison, "~> 4.0.1"}
    ]
  end
end
