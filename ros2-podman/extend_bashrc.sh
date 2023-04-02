#!/usr/bin/env bash
# Note: This script requires ros_entrypoint.sh in root dir
# and also requires to be run as root
# This is used for ros2 container.
# Warning: Do not do this on your physical machine.
# Add this to end of your .bashrc script.
if [ -f /ros_entrypoint.sh ]; then
    source /ros_entrypoint.sh
else
    echo "File Not Found: /ros_entrypoint.sh"
fi
