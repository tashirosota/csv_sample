defmodule WebdbElixirCsvSample.MixProject do
  use Mix.Project

  def project do
    [
      app: :webdb_elixir_csv_sample,
      version: "0.1.0",
      elixir: "~> 1.13.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:csv, "~> 2.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp escript do
    [main_module: WebdbElixirCsvSample.CLI]
  end
end
