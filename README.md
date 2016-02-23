# Ircbot

**Just another stupid IRC-Bot**

This is a crappy IRC-Bot based on [ExIrc](https://github.com/bitwalker/exirc)
with no tests for failures. It may kills your cat. But it will be killed highly
concurrent. 'Nuff said.

## Deployment
* copy config/config.example.exs to config/config.prod.exs and
   config/config.dev.exs and modify its values
* `MIX_ENV=prod mix compile`
* `mix run --ho-halt`

## TODO
* RMV-Checks for next bus [!buba]
* Telegram-to-IRC-Gateway
 * Sticker --> ASCII
* official Shitposting
 * Ridiculous replies to random messages; the ride never ends :^)
* Deployment-Script
 * different config for development and production™
 * strange Unicode-Bug
* Tsundere mode
* Handle disconnect
