defmodule Str.MixProject do
  use Mix.Project

  def project do
    [
      app: :str,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :goth]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:google_api_storage, ">= 0.17.0"},
      {:goth, ">= 1.2.0"}
    ]
  end
end
