#
#      x x x x x
#      x x x x x
#      x x x x x
#      x x x x x
#      x x x x x
#      x x x x x
#
# q w e r t y u i o p
#  a s d f g h j k l
#   z x c v b n m
#
# space for errors
#        Phew
BLACK="\033[97;40;1m"
GREEN="\033[97;42;1m"
YELLOW="\033[97;43;1m"
GREY="\033[97;100;1m"
RED="\033[31;40;1m"
NOCOLOR="\033[0m"

function setup_empty_frame {
	local b="$BLACK"
	local g="$GREEN"
	local y="$YELLOW"
	local n="$NOCOLOR"
	
	echo "" >> $1
	echo "      ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n}" >> $1
	echo "      ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n}" >> $1
	echo "      ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n}" >> $1
	echo "      ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n}" >> $1
	echo "      ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n}" >> $1
	echo "      ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n} ${b}_${n}" >> $1
	echo "" >> $1
	echo " ${b}q${n} ${b}w${n} ${b}e${n} ${b}r${n} ${b}t${n} ${b}y${n} ${b}u${n} ${b}i${n} ${b}o${n} ${b}p${n}" >> $1
	echo "  ${b}a${n} ${b}s${n} ${b}d${n} ${b}f${n} ${b}g${n} ${b}h${n} ${b}j${n} ${b}k${n} ${b}l${n}" >> $1 
	echo "   ${b}z${n} ${b}x${n} ${b}c${n} ${b}v${n} ${b}b${n} ${b}n${n} ${b}m${n}" >> $1
	echo "\n" >> $1
	echo "" >> $1
}

function draw_frame {
	echo -ne "\033[1A"
	echo -ne "\r\033[K"
	echo -ne "\033[11A"
	echo -ne "$(cat $1)"
	echo -ne "\033[${LINES}D"
	echo -ne "\033[1B"
	echo -ne "\033[${LINES}D"
}
