defmodule Kandesk.MixProject do
  use Mix.Project

  def project do
    [
      app: :kandesk,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      gettext: [sort_by_msgid: true, write_reference_comments: false]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Kandesk.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.9"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.16.1"},
      {:phoenix_live_dashboard, "~> 0.5.0"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:argon2_elixir, "~> 2.2.1"},
      {:pow, "~> 1.0.24"},
      {:bamboo, "~> 1.6.0"},
      {:bamboo_smtp, "~> 3.0.0"},
      {:ex_cldr, "~> 2.22"},
      {:ex_cldr_numbers, "~> 2.18"},
      {:ex_cldr_dates_times, "~> 2.7"},
      {:tzdata, "~> 1.0.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
