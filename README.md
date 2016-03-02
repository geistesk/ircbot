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

## Deployment/Install
* `$ cp config/config.{example,dev}.exs`
  `$ cp config/config.{example,prod}.exs`
* Modify these files…
* `$ ./efl.sh [ENV]`
 * where ENV could be "dev" or "prod" (default)

## TODO
* Inspect Unicode-Bug
* Telegram-to-IRC-Gateway
 * Sticker --> ASCII
* RMV-Checks for next bus [!buba]
* Weather
* Tsundere mode
* Return title from HTML-Pages if HTTP{,S}-URIs are posted

## License
This software is released under the zlib-License. For further informations have
a look at `LICENSE`.
