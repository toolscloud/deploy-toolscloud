#!/bin/bash

if [ "$1" == "all" ]; then
	sudo docker stop $(sudo docker ps -aq )
	sudo docker rm $(sudo docker ps -aq )
        sudo rm -rf /applications
else
	sudo docker stop $(sudo docker ps -aq | grep -v $(sudo docker ps -aq --filter 'name=data'))
	sudo docker rm $(sudo docker ps -aq | grep -v $(sudo docker ps -aq --filter 'name=data'))
fi

