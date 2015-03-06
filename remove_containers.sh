#!/bin/bash
sudo docker stop $(sudo docker ps -aq | grep -v $(sudo docker ps -aq --filter 'name=data'))
sudo docker rm $(sudo docker ps -aq | grep -v $(sudo docker ps -aq --filter 'name=data'))
sudo rm -rf /applications
