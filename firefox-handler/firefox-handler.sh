# Core info
BUILD_DIRECTORY="$(dirname "$(readlink -f $0)")"
CONTAINER_NAME="firefox_local_container"
IMAGE_NAME="firefox_local_image"
CONTAINER_NETWORK="firefox-net"

# Rules
RO_RULE="ro,nodev,nosuid,noexec"
RW_RULE="rw,nodev,nosuid,noexec"

# Volumes
DOWNLOADS_DIR="/home/$(whoami)/Containers_Data/Firefox/Downloads"
CONTAINER_DOWNLOADS_DIR="/home/firefoxuser/Downloads"

PULSE_SERVER="/run/user/$(id -u)/pulse/native"

# Devices
RENDER="/dev/dri/renderD128"

# Prompt
USAGE_PROMPT="Usage requires one of the following arguments: <build|run|start|stop>"
SUCCESS_PROMPT="succeeded for container $CONTAINER_NAME from image $IMAGE_NAME"
ERROR_PROMPT="failed for container $CONTAINER_NAME from image $IMAGE_NAME"

validateAndPrintExit() {
	if [ $1 -eq 0 ]; then
		echo "$2 $SUCCESS_PROMPT"
	else
		echo "$2 $ERROR_PROMPT"
		exit 1
	fi
}


# At least one argument is needed
if [ $# -eq 0 ]; then
	echo "$USAGE_PROMPT"
	exit 1
fi

case "$1" in
	build)
		echo "Building the firefox browser container image $IMAGE_NAME..."
		podman build -t "$IMAGE_NAME" "$BUILD_DIRECTORY"
		validateAndPrintExit $0 "Build"
	;;
	run)
		echo "Creating $CONTAINER_NAME to mount downloads directory in $DOWNLOADS_DIR..."
		mkdir -p "$DOWNLOADS_DIR"
		validateAndPrintExit $? "Creating firefox downloads directory"
		
		echo "Creating $CONTAINER_NAME custom network $CONTAINER_NETWORK..."
		podman network exists $CONTAINER_NETWORK
		if [ $? -eq 0 ]; then
			echo "$CONTAINER_NETWORK already exists, continuing..."
		else
			podman network create --no-dns $CONTAINER_NETWORK
			validateAndPrintExit $? "Creating $CONTAINER_NAME network $CONTAINER_NETWORK"
		fi
		
		echo "Creating container $CONTAINER_NAME..."
		podman run -d						\
			--userns=keep-id				\
			--cap-drop=ALL					\
			--cap-add=CAP_SYS_CHROOT			\
			--security-opt label=type:container_runtime_t	\
			--security-opt no-new-privileges		\
			--network $CONTAINER_NETWORK			\
			--device $RENDER				\
			--name $CONTAINER_NAME 				\
			--replace					\
				-e DISPLAY=$DISPLAY 			\
				-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY 	\
				-e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR	\
				-e MOZ_ENABLE_WAYLAND=1			\
				-e PULSE_SERVER=unix:$PULSE_SERVER	\
				-v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$RO_RULE\
				-v $DOWNLOADS_DIR:$CONTAINER_DOWNLOADS_DIR:$RW_RULE\
				-v $PULSE_SERVER:$PULSE_SERVER:$RO_RULE \
				$IMAGE_NAME
		validateAndPrintExit $? "Create"
	;;
	start)
		echo "Starting container $CONTAINER_NAME..."
		podman start "$CONTAINER_NAME"
		validateAndPrintExit $? "Start"
	;;
	stop)
		echo "Stoping container $CONTAINER_NAME..."
		podman stop "$CONTAINER_NAME"
		validateAndPrintExit $? "Stop"
	;;
	*)
		echo "That's not a valid argument. $USAGE_PROMPT."	
	;;
esac
