#!/bin/bash

#source tBot
source opi_leds

#exec - execute command in /bin/bash, and get its result
#espeak - get voice message of text (use espeak from linux repo)
#speakru - get voice message of text on russian (use festvox-ru from linux repo)
#sayru - say in speakers on russian 

DEBUG=false
CURL_ARGS="-s" # default "-s"

TOKEN="$(cat bot_token.txt)"
URL="https://api.telegram.org/bot${TOKEN}"
LMidFILE="last_message_id.txt"
DEST=/mnt/hard_drive1/zopiBot_trash

if ! $DEBUG ; then
	TEMP_DIR=/run/user/$(id -u)/telegram_bot
	RAM_JSON=$TEMP_DIR/answer.json
	CMD_FLAG=$TEMP_DIR/cmd_flag.txt
	CMD_ARGS=$TEMP_DIR/cmd_args.txt
	mkdir -p $TEMP_DIR
	[[ -e $RAM_JSON ]] && touch $RAM_JSON ; echo "" > $RAM_JSON
	[[ -e $CMD_FLAG ]] && touch $CMD_FLAG ; echo "" > $CMD_FLAG
	[[ -e $CMD_ARGS ]] && touch $CMD_ARGS
	#TEMP_DIR=$(mktemp -dt "tBot.XXXXXXXX" --tmpdir=/run/user/$(id -u))
	#RAM_JSON=$(mktemp -t "json.XXXXXXXX" --tmpdir=$TEMP_DIR)
	#CMD_FLAG=$(mktemp -t "cmd_flag.XXXXXXXX" --tmpdir=$TEMP_DIR)
	#CMD_ARGS=$(mktemp -t "cmd_args.XXXXXXXX" --tmpdir=$TEMP_DIR)
else
	TEMP_DIR=$(mktemp -dt "tBot.XXXXXXXX" --tmpdir=/run/user/$(id -u))
	#TEMP_DIR="${HOME}/git/bash/telegram_bot/tBot_d"
	RAM_JSON="${TEMP_DIR}/json_d.txt"
	#RAM_JSON=/run/user/1000/tBot.ldfxYEiV/json.IFefd77O
	CMD_FLAG="${TEMP_DIR}/cmd_flag_d.txt"
	CMD_ARGS="${TEMP_DIR}/cmd_args_d.txt"
fi

Array_Element="0"
#if [[ -v RAM_JSON && -n RAM_JSON ]]; then
function UPDATE_ID(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].update_id ; }
function CHAT_ID(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.chat.id ; }
function CHAT_TITLE(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.chat.title ; }
function CHAT_TYPE(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.chat.type ; }
function FROM_USER(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.from.username ; }
function FROM_ID(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.from.id ; }
function FROM_IS_BOT(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.from.is_bot ; }
function MESS_NUMB(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.message_id ; }
function MESS_DATE(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.date ; }
function MESS_TEXT(){ cat "${RAM_JSON}" | jq -rM .result[${Array_Element}].message.text ; }
#else
#	echo "Json file not set!"
#fi

function parse_text(){
	VAR=$(cat $CMD_ARGS | awk '{print $1}')
# find commands in message
	if [[ $( echo $VAR | awk '{gsub(/\/\w+/,"TRUE",$0);print $0}') == "TRUE" ]]; then
		case $VAR in
			"/espeak" )
				echo "espeak" > $CMD_FLAG	;;
			"/speakru")
				echo "speakru" > $CMD_FLAG	;;
			"/exec" )
				echo "exec" > $CMD_FLAG	;;
			"/sayru" )
				echo "sayru" > $CMD_FLAG	;;
		esac
# if get flag, execute apropriate command
	elif [[ $(cat $CMD_FLAG) != "" ]]; then
		case $(cat $CMD_FLAG) in
			espeak )
				send_Tvoice $CMD_ARGS
				;;
			speakru )
				send_TvoiceRU $CMD_ARGS
				;;
			exec )
				RESULT=$( $(cat $CMD_ARGS) )
				send_Tmess "$RESULT"
				;;
			sayru )
				sayru_alsa $CMD_ARGS
				;;
		esac
		echo "" > $CMD_FLAG
# if not find any, do echo
	else
		send_Tmess $CMD_ARGS
	fi
}

# Make logs
function log(){
	echo -e "[$(date +"%x %X")] $1" >> status.log
}

function send_Tmess(){
	local MESSAGE="$(cat $1)"
	curl $CURL_ARGS -X POST "${URL}/sendMessage?" -d chat_id=$(CHAT_ID) -d text="${MESSAGE}" # > /dev/null
	log "[STAT] send message with exit status ${?}"
	log "	${MESSAGE}"
}

function sayru_alsa(){
	# func wait for /path/to/file like first argument
	local VOICE_FILE="$TEMP_DIR/$(MESS_DATE)_$(FROM_USER)"
	cat $1 | text2wave -o ${VOICE_FILE}.wav
	play -q ${VOICE_FILE}.wav &  > /dev/null 2>&1
	[[ "$(uname -n)" == "orangepizero" ]] && mv ${VOICE_FILE}.wav $DEST > /dev/null  2>&1 || rm -f ${VOICE_FILE}.wav
}

function send_Tvoice(){
	local VOICE_FILE="$TEMP_DIR/$(MESS_DATE)_$(FROM_USER)"
	espeak -w ${VOICE_FILE}.wav "$( cat $1 )"
	ffmpeg -i ${VOICE_FILE}.wav ${VOICE_FILE}.ogg 2>&1 > /dev/null 
	curl $CURL_ARGS -X POST "${URL}/sendVoice?chat_id=$(CHAT_ID)&" -F "voice=@${VOICE_FILE}.ogg" # > /dev/null 2>&1
	log "[STAT] send response with exit status ${?}"
	log "	$( cat $1 )"
	[[ $(uname -n) == "orangepizero" ]] && mv ${VOICE_FILE}.wav $DEST > /dev/null 2>&1
	rm -f ${VOICE_FILE}.wav
	rm -f ${VOICE_FILE}.ogg
}

function send_TvoiceRU(){
	# func wait for /path/to/file like first argument
	local VOICE_FILE="$TEMP_DIR/$(MESS_DATE)_$(FROM_USER)"
	cat $1 | text2wave -o ${VOICE_FILE}.wav
	ffmpeg -i ${VOICE_FILE}.wav ${VOICE_FILE}.ogg > /dev/null 2>&1
	curl $CURL_ARGS -X POST "${URL}/sendVoice?chat_id=$(CHAT_ID)&" -F "voice=@${VOICE_FILE}.ogg" # > /dev/null 2>&1
	[[ $(uname -n) == "orangepizero" ]] && mv ${VOICE_FILE}.wav $DEST > /dev/null 2>&1
	rm -f ${VOICE_FILE}.wav
	rm ${VOICE_FILE}.ogg
}

function send_Tphoto(){
	local PHOTO="$1"
	curl $CURL_ARGS -X POST "${URL}/sendPhoto?chat_id=$(CHAT_ID)&" -F "photo=@${PHOTO}" # > /dev/null 2>&1
}

function get_Updates(){
	echo "$(curl $CURL_ARGS -X GET "${URL}/getUpdates" )"
}

function get_Tlast_message(){
	LAST_MESSAGE_ID=$(cat ${LMidFILE})
	echo "$(curl $CURL_ARGS -X GET "${URL}/getUpdates?" -d offset=${LAST_MESSAGE_ID} -d limit=1 )"
}


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
