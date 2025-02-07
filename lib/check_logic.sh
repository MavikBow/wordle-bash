source ./lib/frame_drawer.sh

target_length=5

# Store constraints in arrays for hard mode
declare -a greens
declare -a yellows
feedback_str=""

function check_guess {
	local guess="$1"
	local result=""

  # Temporary count arrays to handle letter positions
  local target_counts=()
  for ((i = 0; i < target_length; i++)); do
	  target_counts[$i]=0
  done

  # First pass: Check for green letters
  for ((i = 0; i < target_length; i++)); do
	  if [ "${guess:i:1}" == "${target:i:1}" ]; then
		  result="${result}G"
		  greens[$i]="${guess:i:1}"  # Store constraint for hard mode
		  target_counts[$i]=1  # Mark letter as matched
	  else
		  result="${result}_"
	  fi
  done

  # Second pass: Check for yellow letters
  for ((i = 0; i < target_length; i++)); do
	  if [ "${result:i:1}" == "G" ]; then
		  continue
	  fi
	  letter="${guess:i:1}"
	  if [[ "$target" == *"$letter"* ]]; then
		  for ((j = 0; j < target_length; j++)); do
			  if [ "${target:j:1}" == "$letter" ] && [ "${target_counts[$j]}" -eq 0 ]; then
				  result="${result:0:$i}Y${result:$(($i + 1))}"
				  target_counts[$j]=1
				  yellows+=("$letter")  # Store yellow letter constraint
				  break
			  fi
		  done
	  fi
  done

  feedback_str="$result"
}

function enforce_hard_mode {
	local guess="$1"
	local frame_file="$2"

  # Check greens
  for ((i = 0; i < target_length; i++)); do
	  if [ -n "${greens[$i]}" ] && [ "${guess:i:1}" != "${greens[$i]}" ]; then
		sed -i "12s/.*/  must use '${greens[$i]}' at $(( i + 1 ))\n/" $frame_file
		  return 1
	  fi
  done

  # Check yellows
  for yellow in "${yellows[@]}"; do
	  if [[ "$guess" != *"$yellow"* ]]; then
		sed -i "12s/.*/  must include '$yellow'\n/" $frame_file
		  return 2
	  fi
  done

  return 0
}

function supply_string {
	local guess="$1"
	local feedback_str="$2"
	local frame_file="$3"
	local attempt_number=$4

	local final_str="     "
	for ((i = 0; i < target_length; i++)); do
		regex="\\\033\[.{3,10}m${guess:i:1}\\\033\[0m"
		case "${feedback_str:i:1}" in
			_) final_str+=" \\${BLACK}${guess:i:1}\\${NOCOLOR}"
				# Draws them in red
				# Can't use the colors from frame_drawer because
				# the stupid [ has to be \[. otherwise sed won't do it
				replacement="\\\033\[31;40;1m${guess:i:1}\\\033\[0m"
				sed -i -r "9,11s/$regex/$replacement/g" $frame_file
				;;
			Y) final_str+=" \\${YELLOW}${guess:i:1}\\${NOCOLOR}"
				# Draws in yellow
				replacement="\\\033\[97;43;1m${guess:i:1}\\\033\[0m"
				sed -i -r "9,11s/$regex/$replacement/g" $frame_file
				;;
			G) final_str+=" \\${GREEN}${guess:i:1}\\${NOCOLOR}"
				# Draws in green
				replacement="\\\033\[97;42;1m${guess:i:1}\\\033\[0m"
				sed -i -r "9,11s/$regex/$replacement/g" $frame_file
				;;
		esac
	done
	sed -i "$(( 1 + $attempt_number ))s/.*/$final_str/" $frame_file
}

# parameters are: $target $guess $frame_file $is_hard_mode $attempt_number
function process_guess {
	local target="$1"
	local guess="$2"
	local frame_file="$3"
	local hard_mode=$4
	local attempt_number=$5

	if [ $hard_mode -eq 1 ]; then
		enforce_hard_mode "$guess" "$frame_file" || return $?
	fi

	check_guess "$guess" "$frame_file"

	# echos to the frame_file to render later
	supply_string "$guess" "$feedback_str" "$frame_file" $attempt_number

	if [[ "$guess" == "$target" ]]; then
		return 69
	fi

	return 0
}
