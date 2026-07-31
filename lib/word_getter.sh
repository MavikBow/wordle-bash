# pass the date to it in format YYYY/MM/DD
# if no date, then today is used
function get_word {
	local date_str
	local word=""

	if [ -n "$1" ]; then
		date_str=$(date -d "$1" +%Y-%m-%d)
		if [ $? -ne 0 ]; then return 2; fi
	else
		date_str=$(date +%Y-%m-%d)
	fi

	if command -v curl &> /dev/null; then
		word=$(timeout 7s curl -s "https://www.nytimes.com/svc/wordle/v2/${date_str}.json" | sed -n 's/.*"solution":"\([a-z]*\)".*/\1/p')
	elif command -v wget &> /dev/null; then
		word=$(timeout 7s wget -qO- "https://www.nytimes.com/svc/wordle/v2/${date_str}.json" | sed -n 's/.*"solution":"\([a-z]*\)".*/\1/p')
	elif command -v openssl &> /dev/null; then
		word=$(timeout 7s echo -e "GET /svc/wordle/v2/$1.json HTTP/1.1\r\nHost: www.nytimes.com\r\nConnection: close\r\n\r\n" | openssl s_client -connect www.nytimes.com:443 -quiet 2> /dev/null | sed -n 's/.*"solution":"\([a-z]*\)".*/\1/p')
	fi

	if [ -n "$word" ]; then
		echo "$word";
		return 0;
	else
		return 1;
	fi
}

function get_word_rand {
	local number=$(( $RANDOM % 2309 + 1 ))
	sed -n "${number}p" "$dirname/.answerlist.txt"
}
