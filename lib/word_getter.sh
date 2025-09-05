# pass the $date_str to it
function get_from_curl {
	if [[ $(which curl) ]]; then
		timeout 7s curl -s "https://www.nytimes.com/svc/wordle/v2/$1.json" | sed -n 's/.*"solution":"\([a-z]*\)".*/\1/p'
	fi
}

function get_from_wget {
	if [[ $(which wget) ]]; then
		timeout 7s wget -qO- "https://www.nytimes.com/svc/wordle/v2/$1.json" | sed -n 's/.*"solution":"\([a-z]*\)".*/\1/p'
	fi
}

function get_from_openssl {
	if [[ $(which openssl) ]]; then
		timeout 7s echo -e "GET /svc/wordle/v2/$1.json HTTP/1.1\r\nHost: www.nytimes.com\r\nConnection: close\r\n\r\n" | openssl s_client -connect www.nytimes.com:443 -quiet 2> /dev/null | sed -n 's/.*"solution":"\([a-z]*\)".*/\1/p'
	fi
}

# pass the date to it in format YYYY/MM/DD
# if no date, then today is used
function get_word {
	if [ -n "$1" ]; then
		date_str=$(date -d $1 +%Y-%m-%d)
		if [ $? -ne 0 ]; then return 2; fi
	else
		date_str=$(date +%Y-%m-%d)
	fi

	temp1=$(mktemp)
	temp2=$(mktemp)
	temp3=$(mktemp)

	get_from_curl "$date_str" > "$temp1" &
	pid1=$!
	get_from_wget "$date_str" > "$temp2" &
	pid2=$!
	get_from_openssl "$date_str" > "$temp3" &
	pid3=$!

	wait $pid1
	wait $pid2
	wait $pid3

	word_curl=$(<"$temp1")
	word_wget=$(<"$temp2")
	word_openssl=$(<"$temp3")

	rm "$temp1" "$temp2" "$temp3"

	if [ -n "$word_curl" ]; then
		echo "$word_curl"
	elif [ -n "$word_wget" ]; then
		echo "$word_wget"
	elif [ -n "$word_openssl" ]; then
		echo "$word_openssl"
	else 
		return 1
	fi

	return 0
}

function get_word_rand {
	number=$(( $RANDOM % 2309 + 1 ))
	sed -n "${number}p" "$dirname/.answerlist.txt"
}
