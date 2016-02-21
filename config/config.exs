use Mix.Config

config :ircbot,
  # General IRC-Settings
  ircHost: "alvarpi.hsmr.dn42",
  ircPort: 9999,
  ircSsl:  true,
  ircNick: "hsmrBot",
  ircPass: "topkeklel",
  ircUser: "hsmrBot",
  ircName: "Just another Bot :3",
  ircChan: ["#hsmr"],

  # FreifunkaGreetingHandler
  freifunkaHost: "2001:4dd0:fc15:cafe:208:54ff:fe55:1498",
  freifunkaGreet: [
    "Es freut uns, dass du über den Webchat zu uns gefunden hast.",
    "Falls du Fragen hast, stelle sie einfach. Bitte bedenke, dass es aber etwas dauer kann, bis wer antwortet…",
    "Sollte es dringend sein, so erwähne in deiner Nachricht einfach oleander, manu oder nwspk."],

  doorSpaceApi: "https://hsmr.cc/spaceapi.json",

  greetingNew: "Herzlich Willkommen! Schön, dass du hier mal vorbei schaust.",
  greetingOld: "Schön, dass du mal wieder vorbei schaust…",

  magicConchAnswers: ["Heute", "Morgen", "So wird das nichts", "Versuch es nochmal",
                      "Das war super", "Ja", "Nein", "Vielleicht", "Mach mal 'ne Pause",
                      "Frag Mutti", "Vergiß es", "Mach weiter"]
