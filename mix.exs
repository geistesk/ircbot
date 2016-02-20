defmodule Ircbot.Mixfile do
  use Mix.Project

  def project do
    [app: :ircbot,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      mod: {HsmrIrc, []},
      applications: [:exirc, :httpoison, :logger]
    ]
  end

  defp deps do
    [{:exirc, "~> 0.9.2"},
     {:spaceapi, "~> 0.1.1"},
     {:httpoison, "~> 0.8.0"}]
  end
end
