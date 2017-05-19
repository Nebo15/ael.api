defmodule Ael.Mixfile do
  use Mix.Project

  @version "0.1.5"

  def project do
    [app: :ael_api,
     description: "Media content storage access control system that work on top of Signed URL's.",
     package: package(),
     version: @version,
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test],
     docs: [source_ref: "v#\{@version\}", main: "readme", extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger, :confex, :runtime_tools, :logger_json, :poison,
                          :cowboy, :httpoison,
                          :phoenix, :multiverse,
                          :eview, :ecto, :phoenix_ecto,
                          :crypto, :public_key],
     mod: {Ael, []}]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:distillery, "~> 1.2"},
     {:confex, "~> 2.0"},
     {:logger_json, "~> 0.4.0"},
     {:poison, "~> 3.1"},
     {:cowboy, "~> 1.1"},
     {:httpoison, "~> 0.11.1"},
     {:phoenix, "~> 1.3.0-rc"},
     {:multiverse, "~> 0.4.3"},
     {:eview, "~> 0.10.1"},
     {:ecto, "~> 2.1"},
     {:phoenix_ecto, "~> 3.2"},
     {:benchfella, ">= 0.3.4", only: [:dev, :test]},
     {:ex_doc, ">= 0.15.0", only: [:dev, :test]},
     {:excoveralls, ">= 0.5.0", only: [:dev, :test]},
     {:dogma, ">= 0.1.12", only: [:dev, :test]},
     {:credo, ">= 0.5.1", only: [:dev, :test]}]
  end

  # Settings for publishing in Hex package manager:
  defp package do
    [contributors: ["Nebo #15"],
     maintainers: ["Nebo #15"],
     licenses: ["LISENSE.md"],
     links: %{github: "https://github.com/nebo15/ael.api"},
     files: ~w(lib LICENSE.md mix.exs README.md)]
  end
end
