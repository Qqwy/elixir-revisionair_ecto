defmodule RevisionairEcto.Mixfile do
  use Mix.Project

  def project do
    [app: :revisionair_ecto,
     version: "1.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env),
     aliases: aliases(),

     name: "RevisionairEcto",
     description: description(),
     package: package(),
     source_url: "https://github.com/Qqwy/elixir_revisionair_ecto"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:revisionair, "~> 0.10"},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.13"},
      {:poison, "~> 3.1"},

      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  # Ensures `test/support/*.ex` files are read during tests
  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      # Ensures database is reset before tests are run
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      name: :revisionair_ecto,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Wiebe-Marten Wijnja/Qqwy"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Qqwy/elixir_revisionair_ecto"}
    ]
  end

  defp description do
    """
    A Revisionair Storage Adapter based on Ecto. Keeps track of revisions, changes, versions of your data structures.
    """
  end
end
