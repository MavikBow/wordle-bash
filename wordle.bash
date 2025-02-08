#!/bin/env bash

source ./lib/word_getter.sh
source ./lib/help_menu.sh
source ./lib/frame_drawer.sh
source ./lib/check_logic.sh

error_code=0
hard_mode=0
date_chosen=0
random_chosen=0
word=""

if [ $# -eq 0 ]; then
	word=$(get_word)	
	error_code=$?
else
	while [ -n "$1" ]; do
		case "$1" in
			-h|-\?|help|--help) 
				print_help
				exit 0
				;;

			-H|-hm|hard|--hard) 
				hard_mode=1
				if [[ $# -eq 1 && $random_chosen -eq 0 && $date_chosen -eq 0 ]]; then
					word=$(get_word)	
					error_code=$?
				fi
				;;

			-d|date|--date) 
				if [ $random_chosen -eq 1 ]; then
					print_unexpected
					exit 0
				fi
				# stupid long regex that forces YYYY/MM/DD format and forbids dates earlier that 2021/06/19
				# this regex also need to allow "today", "yesterday" and "tomorrow"
				if [[ ! $2 =~ ^(2021\/(06\/(19|2[0-9]|30)|(0[7-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]))$|^(202[2-9]|20[3-9][0-9]|2[1-9][0-9][0-9]|[3-9][0-9]{3}|[1-9][0-9]{4,})\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]))|(today)|(yesterday)|(tomorrow)$ ]]
				then
					print_bad_date
					exit 0
				fi
				word=$(get_word $2)	
				error_code=$?
				date_chosen=true
				shift
				;;

			-r|random|--random) 
				if [ $date_chosen -eq 1 ]; then
					print_unexpected
					exit 0
				else
					word=$(get_word_rand)
					random_chosen=true
				fi
				;;

			*)
				print_unexpected
				exit 0
				;;
		esac
		shift
	done
fi

if [[ $error_code -eq 1 ]]; then
	echo "wordle.bash: Either you're offline or you're trying to look too far into the future."
	echo "Please check your internet connection and try again. If you're connected to Wi-Fi, make sure it's working properly."
	exit 0
elif [[ $error_code -eq 2 ]]; then
	print_bad_date
	exit 0
elif [ -z "$word" ]; then
	echo "wordle.bash: Something went wrong."
fi

# main game loop

word="${word:0:5}"
frame_file=$(mktemp)
setup_empty_frame $frame_file
echo -ne "$(cat $frame_file)"
max_attempts=6
now_attempt=1

while true; do
	read input_raw
	echo -ne "\033[1A"
	echo -ne "\r\033[K"
	input_arr=($input_raw)
	input_str=$(echo ${input_arr[0]} | awk '{ print tolower($0) }')

	if [[ $input_str =~ ^(:(q|quit|exit))|(quit|exit)$ ]]; then
		break
	elif [[ $input_str =~ ^[a-z]{5}$ ]]; then
		if [[ -z "$(grep -F "$input_str" .wordlist.txt)" ]]; then
			sed -i '12s/.*/  not in word list\n/' $frame_file
		else
			sed -i '12s/.*/ /' $frame_file
			# here should be the main logic
			# parameters are: $target $guess $frame_file $is_hard_mode $attempt_number
			process_guess $word $input_str $frame_file $hard_mode $now_attempt
			exit_status=$?
			if [ "$exit_status" -eq 69 ]; then
				case $now_attempt in
					1) sed -i "12s/.*/      \\\033\[97;42;1mGenius\\\033[0m\n/" $frame_file ;;
					2) sed -i "12s/.*/    \\\033\[97;42;1mMagnificent\\\033\[0m\n/" $frame_file ;;
					3) sed -i "12s/.*/     \\\033\[97;42;1mImpressive\\\033\[0m\n/" $frame_file ;;
					4) sed -i "12s/.*/      \\\033\[97;42;1mSplendid\\\033\[0m\n/" $frame_file ;;
					5) sed -i "12s/.*/        \\\033\[97;42;1mGreat\\\033\[0m\n/" $frame_file ;;
					6) sed -i "12s/.*/        \\\033\[97;42;1mPhew\\\033\[0m\n/" $frame_file ;;
				esac
				break
			elif [ "$exit_status" -eq 0 ]; then
				now_attempt=$(( $now_attempt + 1 ))
				if [ $now_attempt -eq 7 ]; then
					break
				fi
			fi
		fi
	else
		sed -i '12s/.*/  unknown command\n/' $frame_file
	fi

	draw_frame $frame_file

done

draw_frame $frame_file
rm $frame_file
exit 0
