#!/usr/bin/env bash
# WARNING: YOU CANNOT RUN THIS. EVEN IF YOU CAN, DO NOT TRY THIS ON YOUR PC.
# Not much of a hassle even if you run this.
# Add this to end of your .bashrc script.s
if [ -f /ros_entrypoint.sh ]; then
    source /ros_entrypoint.sh
else
    echo "File Not Found: /ros_entrypoint.sh"
fi
