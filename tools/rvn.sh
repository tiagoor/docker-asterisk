#!/bin/bash

# Give everything meaningful names
NAME_ASTERISK=asterisk
NAME_FASTAGI=fastagi

# Do some cleanup.
#echo "Kill all containers"
#docker kill $(docker ps -a -q)
#echo "Removing all containers"
#docker rm $(docker ps -a -q)

# Run the fastagi container.
docker run \
	-p 4573:4573 \
	--name $NAME_FASTAGI \
	-d -t thx1138/fastagi

# Run the main asterisk container.
docker run \
    --name $NAME_ASTERISK \
    --net=host \
    -d -t thx1138/asterisk

# -----------------------------
# Some helpful debug stuff...
# docker run --name $NAME_ASTERISK --net=host -d -t dougbtv/asterisk
# For testing use:
# docker run --name $NAME_ASTERISK --net=host -i -t dougbtv/asterisk bin/bash
