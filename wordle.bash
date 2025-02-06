#!/bin/bash

source ./word_getter.sh
source ./help_menu.sh
source ./frame_drawer.sh

error_code=0
hard_mode=0
date_chosen=0
random_chosen=0
word=""

if [ $# -eq 0 ]; then
	word=$(get_word)	
else
	while [ -n "$1" ]; do
		case "$1" in
			-h|-\?|help|--help) 
				print_help
				exit 0
				;;

			-H|-hm|hard|--hard) 
				hard_mode=1 
				;;

			-d|date|--date) 
				if [ $random_chosen -ne 0 ];then
					print_unexpected
					exit 0
				fi
				# stupid long regex that forces YYYY/MM/DD format and forbids dates earlier that 2021/06/19
				if [[ ! $2 =~ ^2021\/(06\/(19|2[0-9]|30)|(0[7-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01]))$|^(202[2-9]|20[3-9][0-9]|2[1-9][0-9][0-9]|[3-9][0-9]{3}|[1-9][0-9]{4,})\/(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01])$ ]]
				then
					print_bad_date
					exit 0
				fi
				word=$(get_word $2)	
				error_code=$?
				if [[ $error_code -eq 2 ]]; then
					print_bad_date
					exit 0
				fi
				date_chosen=1
				shift
				;;

			-r|random|--random) 
				if [ $date_chosen -ne 0 ];then
					print_unexpected
					exit 0
				else
					word=$(get_word_rand)
					random_chosen=1
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

if [ $error_code -eq 1 ] || [ -z "$word" ]; then
	echo "wordle.bash: It seems you're offline."
	echo "Please check your internet connection and try again. If you're connected to Wi-Fi, make sure it's working properly."
	exit 0
else
	echo $word
fi

# main game loop

is_running=1
frame_file=$(mktemp)
setup_empty_frame $frame_file
echo -ne "$(cat $frame_file)"

while [ $is_running -eq 1 ]; do
	read -n 30 -r input_raw
	tput cuu1
	tput el
	input_arr=($input_raw)
	input_str=$(echo ${input_arr[0]} | awk '{ print tolower($0) }')

	rerer=$(mktemp)
	
	if [[ $input_str =~ ^(:(q|quit|exit))|(quit)|(exit)$ ]]; then
		exit 0
	elif [[ $input_str =~ ^[a-z]{5}$ ]]; then
		if [[ -z "$(grep -F "$input_str" .wordlist.txt)" ]]; then
			sed -i '12s/.*/  not in word list\n/' $frame_file
		else
			sed -i '12s/.*/ /' $frame_file
		fi
	else
		sed -i '12s/.*/  unknown command\n/' $frame_file
	fi

	draw_frame $frame_file

done
