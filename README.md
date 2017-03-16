# IrcBot

**Just another stupid IRC-Bot**

This is a crappy IRC-Bot based on [ExIrc](https://github.com/bitwalker/exirc)
with no tests for failures. It may kills your cat. But it will be killed somewhat
concurrent. It was written to get into Elixir, support the IRC-channel of our
hackspace and have some fun. 'Nuff said.

## Functionality
### Active
```
!help↲
<@testBot> ⇢ !ask QUESTION   Gives a random answer to the given QUESTION
<@testBot> ⇢ !base           Checks the Space API and returns if the hackspace is occupied
<@testBot> ⇢ !bell help      !bell is a module to notify some registered at once.
<@testBot> ⇢ !flti           Returns the date of the next FLTI*-times in our hackspace
<@testBot> ⇢ s/FOO/BAR/      Resends your last message where FOO is replaced with BAR. RegEx is possible
```
### Passive
* Greeting everyone who connects through the FFMR-Webchat
* Parsing URLs and trying to return the title of HTML-documents
* Posting Telegram-messages, images, files and stickers into the IRC
* Starting a HTTP-Server to receive RESTfull-JSONs

## Deployment/Install
You need to have a installed binary of `dwebp` (`libwebp`-package on Arch) to
convert the Telegram-stickers to jpgs.

* `$ cp config/config.{example,dev}.exs`
* `$ cp config/config.{example,prod}.exs`
* Modify these files…
* `$ mix deps.get`
* `$ ./run.sh [ENV]`
 * where ENV could be "dev" or "prod" (default)
 * to run it with systemd:
 * `# cp ircbot.service /usr/lib/systemd/system/`
 * and modify this file afterwards.

## Charset
For some reasons this seems to be still a topic in *>current year*…
I discovered some strange behaviors with everything which is not ANSI. It seems
like the bot parsed it - for some reasons - as ISO-8859-n. However, I am using
a ZNC-Bouncer between the bot and the server.
So I just tried a bit and reconfigured the bouncer. Maybe have a look in the
[ZNC-wiki](http://wiki.znc.in/Charset).
> Client encoding: Try to parse as UTF-8 and as ISO-8859-15

## TODO
* RMV-Checks for next bus [!buba]
* Improve UrlHandler

## License
This software is released under the zlib-License. For further informations have
a look at `LICENSE`.
