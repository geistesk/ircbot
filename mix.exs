defmodule Ircbot.Mixfile do
  use Mix.Project

  def project do
    [app: :ircbot,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     # escript: [main_module: HsmrIrc],
     deps: deps]
  end

  def application do
    [
      mod: {HsmrIrc, []},
      applications: [:exirc, :httpoison, :spaceapi, :poison]
    ]
  end

  defp deps do
    [{:exirc, "~> 0.9.2"},
     {:spaceapi, "~> 0.1.2"},
     {:httpoison, "~> 0.8.0"},
     {:json, "~> 0.3.0"},
     {:exrm, "~> 1.0.0-rc8"},
     {:cf, "~> 0.2.1", override: true}, # remove this later
     {:erlware_commons, github: "erlware/erlware_commons", override: true}] # remove this later
  end
end
