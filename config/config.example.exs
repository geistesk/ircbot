use Mix.Config

config :ircbot,
  # General IRC-Settings
  ircHost: "irc.network.foo",
  ircPort: 6667,
  ircSsl:  false,
  ircNick: "testBot",
  ircPass: "",
  ircUser: "test bot",
  ircName: "Just another Bot :3",
  ircChan: ["#test"],

  bellConfigFile: "bellconf.json"

config :logger,
  level: :info
