# --- detect OS ----------------------------------------------------------------
case "${OSTYPE:-$(uname -s | tr '[:upper:]' '[:lower:]')}" in
darwin*|*bsd*) HOST_OS=mac ;;
linux*|cygwin*|msys*|mingw*) HOST_OS=linux ;;
*)
  echo "Unsupported OS: ${OSTYPE:-unknown}" >&2
  # I won't make it crash in case you've got some cryptic OS
  HOST_OS=linux
  #exit 1
  ;;
esac
#echo "Detected host: $HOST_OS"

if [[ "$HOST_OS" == "linux" ]]; then
	function ossed {
		sed -i "$@"
	}
elif [[ "$HOST_OS" == "mac" ]]; then
	function ossed {
		sed -i '' "$@"
	}
fi
