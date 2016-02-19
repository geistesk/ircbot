use Mix.Config

config :ircbot,
  # General IRC-Settings
  ircHost: "alvarpi.hsmr.dn42",
  ircPort:  6660,
  ircNick: "hsmrBot",
  ircPass: "topkeklel",
  ircUser: "hsmrBot",
  ircName: "Just another Bot :3",
  ircChan: ["#hsmr"],

  # FreifunkaGreetingHandler
  freifunkaHost: "2001:4dd0:fc15:cafe:208:54ff:fe55:1498",
  freifunkaGreet: [
    "Es freut uns, dass du es über den Webchat zu uns nach geschafft hast.",
    "Falls du Fragen hast, stelle sie einfach. Bitte bedenke, dass es aber etwas dauer kann, bis wer antwortet…"]
