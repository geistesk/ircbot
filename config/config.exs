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

  helpMessage: [
    "Commands for hsmrBot:",
    "⇢ !ask FRAGE   Beantwortet die gegebene FRAGE wahrheitsgemäß",
    "⇢ !base        Ist der Space gerade besetzt?",
    "⇢ !bell help   Bell ist ein Modul zum Benachrichtigen von verschiedenen Usern",
    "⇢ !flti        Gibt das Datum der nächsten FLTI*-Zeiten aus",
    "⇢ s/FOO/BAR/   Ersetzt im letzten Post FOO durch BAR. RegEx sind teilweise möglich"
    ],

  # FreifunkaGreetingHandler
  freifunkaHost: "2001:4dd0:fc15:cafe:208:54ff:fe55:1498",
  freifunkaName: ~r/is using a Web IRC client$/,
  freifunkaGreet: [
    "Es freut uns, dass du über den Webchat zu uns gefunden hast.",
    "Falls du Fragen hast, stelle sie einfach. Wenn sich keiner sofort meldet und es dringend ist, so tippe einfach !bell (mit dem führenden Ausrufezeichen)"],

  # DoorHandler
  doorSpaceApi: "https://hsmr.cc/spaceapi.json",

  # MagicConchHandler
  magicConchAnswers: ["Heute", "Morgen", "So wird das nichts", "Versuch es nochmal",
                      "Das war super", "Ja", "Nein", "Vielleicht", "Mach mal 'ne Pause",
                      "Frag Mutti", "Vergiß es", "Mach weiter"],

  bellConfigFile: "bellconf.json"
