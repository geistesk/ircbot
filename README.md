# IrcBot

**Just another stupid IRC-Bot**

This is a crappy IRC-Bot based on [ExIrc](https://github.com/bitwalker/exirc)
with no tests for failures. It may kills your cat. But it will be killed highly
concurrent. It was written to get into Elixir, support the IRC-channel of our
hackspace and have some fun. 'Nuff said.

## Functionality
```
!help↲
<@testBot> ⇢ !ask QUESTION   Gives a random answer to the given QUESTION
<@testBot> ⇢ !base           Checks the Space API and returns if the hackspace is occupied
<@testBot> ⇢ !bell help      !bell is a module to notify some registered at once.
<@testBot> ⇢ !flti           Returns the date of the next FLTI*-times in our hackspace
<@testBot> ⇢ s/FOO/BAR/      Resends your last message where FOO is replaced with BAR. RegEx is possible
```

## Deployment
* copy config/config.example.exs to config/config.prod.exs and
   config/config.dev.exs and modify its values
* `MIX_ENV=prod mix compile`
* `MIX_ENV=mix run --ho-halt`

## Life cycle
The bot starts and tries to connect to the given server. Now it will serve the
IRC-requests. When the connection is closed the bot will stop. If you want to
get it up again, put the startup into an endless loop or let your init-system
do it (systemd is a great choice (^:)

## TODO
* Change license 'cause Germany
* ReplaceHandler: check if last message matches regex
* Handle disconnect
* Inspect Unicode-Bug
* Telegram-to-IRC-Gateway
 * Sticker --> ASCII
* RMV-Checks for next bus [!buba]
* Weather
* official Shitposting
 * Ridiculous replies to random messages; the ride never ends :^)
 * Reduce amount of shit :    >
 * RegEx for GNU/Linux and Coffee
* Tsundere mode
* Return title from HTML-Pages if HTTP{,S}-URIs are posted

## License
Have a look at `UNLICENSE`.
