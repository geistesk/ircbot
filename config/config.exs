use Mix.Config

# Values can be overwritten in config.{dev,prod}.exs

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
  freifunkaHost: "2001:470:1f0b:1c2:4078:78f2:f868:c9ee",
  freifunkaNameIgnore: ~r/(B|b)ern(d|t)/,
  freifunkaUser: "~7f000001",
  freifunkaGreet: [
    "Es freut uns, dass du über den Webchat zu uns gefunden hast.",
    "Falls du Fragen hast, stelle sie einfach. Wenn sich keiner sofort meldet und es dringend ist, so tippe einfach !bell (mit dem führenden Ausrufezeichen)"],

  # DoorHandler
  doorSpaceApi: "https://hsmr.cc/spaceapi.json",

  # MagicConchHandler
  magicConchAnswers: ["Heute", "Morgen", "So wird das nichts", "Versuch es nochmal",
                      "Das war super", "Ja", "Nein", "Vielleicht", "Mach mal 'ne Pause",
                      "Frag Mutti", "Vergiß es", "Mach weiter"],

  telegramPomf: "https://lewd.se"
import_config "config.#{Mix.env}.exs"
