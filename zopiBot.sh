#!/bin/bash

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
CORE_DIR="$(cd $(dirname $0);pwd)"
source ${CORE_DIR}/tBot
source ${CORE_DIR}/config
source ${CORE_DIR}/opi_leds
i=0
#exec - execute command in /bin/bash, and get its result
#espeak - get voice message of text (use espeak from linux repo)
#speakru - get voice message of text on russian (use festvox-ru from linux repo)
#sayru - say in speakers on russian

if ! $DEBUG; then
	echo "0" > "$SIG_to_DIE"
	[[ $(uname -n) == "orangepizero" ]] && init_leds
	while true; do
		# get tor new nym 
		if [[ $i -gt 10 ]];then
			tor_newnym
			i=0
		fi
		# ask server for new massage to bot, if there is, give me 1 pls
		get_Tlast_message
		# update & save last_message_id, according to BOT API
		if [[ "$(UPDATE_ID)" -eq "$(cat "${LMidFILE}" )" && "$(UPDATE_ID)" != "null" ]]; then
			# calc message_id for the next get_Tlast_message
			echo "$(($(UPDATE_ID)+1))" > "$LMidFILE"
			# find if text is command like message
			parse_text

			#blink_led "$LED4"
			#wait $(jobs -p)
		else
			trig_led "$LED5"
			#wait $(jobs -p)
		fi
		#trig_led $LED1 &
		#wait $(jobs -p)
		#sleep 0.013
		if [[ "$DEBUG_OUTPUT" == "true" ]]; then
			debug_info
			sleep 5
		fi
		if [[ "$(cat "${SIG_to_DIE}")" == "9" ]]; then
			exit 0
		fi
	done
else
	LAST_MESSAGE_ID="$(cat "$LMidFILE")"
	echo "$LAST_MESSAGE_ID"
	echo "$(curl -s -X GET "${URL}/getUpdates?" -d offset="${LAST_MESSAGE_ID}" -d limit=1 )" > $RAM_JSON
	echo "$RAM_JSON"
fi

exit $?
