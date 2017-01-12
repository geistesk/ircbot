defmodule Ircbot.Mixfile do
  use Mix.Project

  def project do
    [app: :ircbot,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      mod: {HsmrIrc, []},
      applications: [:exirc, :httpoison, :spaceapi, :poison, :json, :logger]
    ]
  end

  defp deps do
    [{:exirc, "~> 0.11.0"},
     {:spaceapi, "~> 0.1.2"},
     {:httpoison, "~> 0.9.1"},
     {:json, "~> 1.0.0"},
     {:temp, "~> 0.4.1"}]
  end
end
