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

  bellConfigFile: "bellconf.json",

  telegramToken:    "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11",
  telegramChannels: ["#test"],
  telegramChatIds:  [-10000000],

  grafanaRouterUrl:      "/web-hook/",
  grafanaRouterPort:     4001,
  grafanaRouterAuth:     "username:password",
  grafanaRouterChannels: ["#test"]

config :logger,
  level: :info
