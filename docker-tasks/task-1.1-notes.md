## Task 1.1

## which image was used
- busybox:latest

## which commands were run
docker pull busybox
docker run busbox echo "Hello from Docker"
docker pull busybox
docker run busybox echo "Hello from Docker"
docker run busybox ls
docker ps
docker ps -a
docker logs <container_id>
docker rm <container_id>

## what was the output

Hello from docker
anas_c@Anas:~$ docker run busybox ls
bin
dev
etc
home
lib
lib64
proc
root
sys
tmp
usr
var
anas_c@Anas:~$ docker run busybox date

## why the container exited

The container exited due to the main process exited /completed successfully 

## why the container appeared in docker ps -a

The container will be sustained for loggin purpose, we need to remove the container 


## how logs were viewed
The logs are viewed using the command docker logs <container_Id/name>


## why image and container are different
The image is snapshot of the application code,
It will be executed using the command docker build
all the configurations are written in docker file

Container is a runtime environment which runs with the base Image,
which execute the image with the command docker run.

