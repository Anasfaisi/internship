
Task 1.2 notes

## exact docker run command 
docker images
docker ps
docker ps -a

docker pull nginx:latest
docker run -d --name nginx-web -p 8080:80 nginx:latest

docker logs nginx-web
docker logs -f nginx-web
docker inspect nginx-web

docker inspect --format='{{.State.Status}}' nginx-web
docker inspect --format='{{.NetworkSettings.IPAddress}}' nginx-web
docker inspect --format='{{json .HostConfig.PortBindings}}' nginx-web

docker top nginx-web
docker port nginx-web
docker stats --no-stream nginx-web
 
docker exec -it nginx-web sh
ps
ls /
ls /usr/share/nginx/html
exit

docker stop nginx-web

docker rm nginx-web

## Why the container stayed running

The container's main process is still running so it is up and running, 
this is not a short lived container since this is a hosted it is continously listens for new incoming requests.

## What port mapping means
we can see that -p 8080: 80 which means any request comming to the current local machine with port 8080,
will be redirected to the port 22 where the container listens.

## How browser traffic reached teh container
The port mapping is the one who is responsible by redirecting the incoming requests that comes to the server 8080 of the local machine.

## What doecker logs showed

Docker logs showed different running processes
we can also see if someone visited the website 
engine and os Info
ipv6 connection
environment variables

## what docker inspect helped reveal
We can see a huge data we can filter out with certain commands.
Through that we can able to analyse the status of state. 
Ip addresss,port binding etc..

##what docker top showed
It showed the current running process inside the container


## what docker stat --no-stream showed
It shown the current statistics of Cpu usage, 
memory usage,
I/O requests,
block requests

## What was seen using docker exec
It opened up a shell that we can communicate with container, 
run commands like ps, ls etc..

## How stop and remove behavior worked
The stop behaviour stops the container, 
the container is still in exited process 
for cleaning up, removed the container,
the image was still there because they have a different life cycle


