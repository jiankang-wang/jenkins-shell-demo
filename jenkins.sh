#!/bin/bash

CONTAINER=${container_name}
PORT=${port}


# build docker image
docker build --no-cache -t ${image_name}:${tag} .


checkDocker() {
  RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2>/dev/null)
  if [ -z $RUNNING ]; then
    echo "$CONTAINER does not exist."
    return 1
  fi

  if [ "$RUNNING" == "false" ]; then
    matching=$(docker ps -a --filter="name=$CONTAINER" -q | xargs)
    if [ -n $matching ]; then
      docker rm $matching
    fi
    return 2
  else
    echo "$CONTAINER is running."
    matchingStarted=$(docker ps --filter="name=$CONTAINER" -q | xargs)
    if [ -n $matchingStarted ]; then
      docker stop $matchingStarted
      docker rm ${container_name}
    fi
  fi
}

checkDocker


# run docker image
docker run -itd --name $CONTAINER -p $PORT:80 ${image_name}:${tag}