use Mix.Config

config :ircbot,
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
  freifunkaUser: "~7f000001",
  freifunkaGreet: [
    "Es freut uns, dass du über den Webchat zu uns gefunden hast.",
    "Falls du Fragen hast, stelle sie einfach. Wenn sich keiner sofort meldet und es dringend ist, so tippe einfach !bell (mit dem führenden Ausrufezeichen)"],

  # DoorHandler
  doorSpaceApi: "https://hsmr.cc/spaceapi.json",

  # MagicConchHandler
  magicConchAnswers: ["Heute", "Morgen", "So wird das nichts", "Versuch es nochmal",
                      "Das war super", "Ja", "Nein", "Vielleicht", "Mach mal 'ne Pause",
                      "Frag Mutti", "Vergiß es", "Mach weiter"]

import_config "config.#{Mix.env}.exs"
