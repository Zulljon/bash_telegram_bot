# Telegram bot writen on bash
Work well on my OrangePi ZERO
## Function:
> /exec - execute command in /bin/bash, and get its result
> /espeak - get voice message of text (only english)
> /speakru - get voice message of text on russian
> /sayru - say in speakers on russian
> echo

## Usage
1. Create your bot and get his `token`
2. Get the last massege id from json response from server, simple write massege to bot and call getUpdate like so
```bash
$ curl -X GET "https://api.telegram.org/bot${TOKEN}/getUpdates?"
```
3. Do followings
```bash
$ git clone https://github.com/Zulljon/bash_telegram_bot.git 
$ cd bash_telegram_bot
$ echo "your_bot_token" > bot_token.txt
$ echo "last_message_id" > last_message_id.txt
$ ./zopiBot.sh > /dev/null 2>&1 &
```
Bot will take update by one part and process it, so do not change last_message_id.txt.
Hope i demonize it in future=)

## Used programs
Run on Linux Mint and standart OPi OS without X.
All programs is in repo
 - /bin/bash
 - jq
 - curl
 - ffmpeg
 - espeak (standart linux TTS engine)
 - festival (improwed TTS) with festvox-ru package
 - gpio (gpio.sunxi libs from RaspberyPi ported to use with OPi ZERO)
 - play (from alsa package)
 - Telegram API

 P.S. I will add links later.
