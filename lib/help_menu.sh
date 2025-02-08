# stores and prints the help menu
function print_help {
	echo "wordle.bash - a clone of a browser game Wordle by NYT"
	echo ""
	echo "Usage: ./wordle.bash [OPTION...]"
	echo ""
	echo " -h, -?, help, --help		Prints this help menu."
	echo " -hm, -H, hard, --hard		Plays in hard mode, meaning any revealed hints must be used in subsequent guesses."
	echo " -d, date, --date YYYY/MM/DD	Plays a specific day. Note, you can't go earlier than 2021/06/19."
	echo "				today, yesterday and tomorrow can be used instead of YY/MM/DD."
	echo " -r, random, --random		Plays a random word from the answer list."
	echo " -q, quiet, --quiet		Stops the answer from showing upon losing."
	echo ""
	echo "In-game commands:"
	echo ""
	echo " :q, :quit, :exit, quit, exit   Quits the game."
	echo ""
	echo "Source code for this is available at <https://github.com/MavikBow/wordle-bash/>"
}

function print_unexpected {
	echo "wordle.bash: unexpected options."
	echo "Try './wordle.bash --help' for more information."
}

function print_bad_date {
	echo "wordle.bash: bad date format."
	echo "Try './wordle.bash --help' for more information."
}
