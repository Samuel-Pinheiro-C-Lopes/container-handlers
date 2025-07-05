#MOUTING PROFILE
#PROFILE_DIR="$PWD/browser-profile"
#CONTAINER_PROFILE_DIR="/home/browseruser/.mozilla/firefox"
#-v "$PROFILE_DIR":"$CONTAINER_PROFILE_DIR":Z	\
#OPTS
#-v /tmp/.X11-unix:/tmp/.X11-unix:ro	\
#-e XDG_SESSION_TYPE=$XDG_SESSION_TYPE   \
# DBUS
#-e DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus\
#-v /etc/machine-id:/etc/machine-id:ro	\

BUILD_DIRECTORY="$(dirname "$(readlink -f $0)")"

CONTAINER_NAME="firefox_local_container"
DOCKERFILE_DIR="$BUILD_DIRECTORY"
IMAGE_NAME="firefox_local_image"

DOWNLOADS_DIR="/home/$(whoami)/Containers Data/Firefox/Downloads"
CONTAINER_DOWNLOADS_DIR="/home/firefoxuser/Downloads"

USAGE="Usage requires one of the following arguments: <build|run|start|stop>"

# At least one argument is needed
if [ $# -eq 0 ]; then
	echo "$USAGE"
	exit 1
fi

case "$1" in
	build)
		echo "Building the firefox browser container image $IMAGE_NAME..."
		podman build -t "$IMAGE_NAME" "$DOCKERFILE_DIR"
		if [ $? -eq 0 ]; then
			echo "Image $IMAGE_NAME built with success."
		else
			echo "The image $IMAGE_NAME build failed."
			exit 1
		fi
	;;
	run)
		echo "Creating firefox downloads directory in $DOWNLOADS_DIR..."
		mkdir -p "$DOWNLOADS_DIR"
		if [ $? -eq 0 ]; then
			echo "Created firefox downloads with success."
		else
			echo "Firefox downloads directory creation failed."
			exit 1
		fi
		echo "Creating container $CONTAINER_NAME..."
		podman run -d						\
			--userns=keep-id				\
			--cap-drop=ALL					\
			--cap-add=CAP_SYS_CHROOT			\
			--security-opt label=type:container_runtime_t	\
			--device /dev/dri/renderD128			\
			--name $CONTAINER_NAME				\
			--replace					\
				-e DISPLAY=$DISPLAY 			\
				-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY 	\
				-e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR	\
				-e MOZ_ENABLE_WAYLAND=1			\
				-e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native\
				-v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:ro,noexec,nosuid,nodev\
				-v "$DOWNLOADS_DIR":"$CONTAINER_DOWNLOADS_DIR":rw,noexec,nosuid,nodev\
				-v /run/user/$(id -u)/pulse/native:/run/user/$(id -u)/pulse/native:ro,noexec,nosuid,nodev \
				"$IMAGE_NAME"
		if [ $? -eq 0 ]; then
			echo "Container $CONTAINER_NAME created with success."
		else 
			echo "Attempt to create container $CONTAINER_NAME failed."
		fi
	;;
	start)
		echo "Starting container $CONTAINER_NAME..."
		podman start "$CONTAINER_NAME"
		if [ $? -eq 0 ]; then
			echo "Container $CONTAINER_NAME started with success."
		else 
			echo "Attempt to start container $CONTAINER_NAME failed."
		fi
	;;
	#enter)
	#	echo "Entering container $CONTAINER_NAME..."
	#	podman exec "$CONTAINER_NAME" /bin/bash
	#;;
	stop)
		echo "Stoping container $CONTAINER_NAME..."
		podman stop "$CONTAINER_NAME"
		if [ $? -eq 0 ]; then
			echo "Container $CONTAINER_NAME stopped with success."
		else 
			echo "Attempt to start container $CONTAINER_NAME failed."
		fi
	;;
	*)
		echo "That's not a valid argument. $USAGE."	
	;;
esac
