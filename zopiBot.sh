#!/bin/bash

source tBot
source opi_leds

#exec - execute command in /bin/bash, and get its result
#espeak - get voice message of text (use espeak from linux repo)
#speakru - get voice message of text on russian (use festvox-ru from linux repo)
#sayru - say in speakers on russian 

if ! $DEBUG; then
	[[ $(uname -n) == "orangepizero" ]] && init_leds
	while true; do
		echo "$(get_Tlast_message)" > $RAM_JSON
		if [[ $(UPDATE_ID) -eq $(cat ${LMidFILE} ) ]]; then
			echo $(($(UPDATE_ID)+1)) > $LMidFILE
			
			echo $(MESS_TEXT) > $CMD_ARGS
			parse_text

			blink_led $LED4 &
			wait $(jobs -p)
		else
			trig_led $LED5 &
			wait $(jobs -p)
		fi
		#trig_led $LED1 &
		#wait $(jobs -p)
		#sleep 0.013
	done
else
	LAST_MESSAGE_ID=$(cat $LMidFILE)
	echo $LAST_MESSAGE_ID
	echo "$(curl -s -X GET "${URL}/getUpdates?" -d offset="${LAST_MESSAGE_ID}" -d limit=1 )" > $RAM_JSON
	echo $RAM_JSON
fi

exit $?
