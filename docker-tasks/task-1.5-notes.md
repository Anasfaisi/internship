## Mandatory Questions to Answer

1. What is the main process inside a Docker container?
- The main process inside in a container is PID 1 ,which is the master process if that stops/finished the entire container will exit.
while the command top shows the pid start from 2215 is given master process and , all others are worker processers

2. Why does a container stop when the main process exits?
- The container's life cycle is tied ot the main process that is running. The container life cycle is depentupon it.

3. Why did the busybox container exit immediately?
- busybox container is a short lived container, where it was assigned to run a process and once it finished it gracefully exited .

4. Why did the nginx container keep running?
- The nginx container is a long lived container , where it was always listening for the incoming requests, 
It was all time up , we need to manually stop and remove the process.

5. What is the difference between a normal exit and a manual stop?
- A normal exit will happen once the process inside a container finished it's execution automatically. 
where as in manual stop we need to run the command like "docker stop" to  exit from the process.
 
6. What does exit code 0 usually indicate?
-  The code exited gracefully without causing any errors, The process  runs and execute and it finished without causing any error.

7. What is the purpose of docker logs in lifecycle debugging?
- If any container exited without 0 , we can easily check at what no of line, on which file the error has happend. 

8. What is the purpose of docker inspect in lifecycle debugging?
- we can easily verify the status of the current docker container,  exit code , started time,
 finished time like that those meta data can be fetched from the inspect to understand the life cyle of a container

9. What is the purpose of docker top?
- docker top will help us show the running process inside in  a container , the main process and working process with uid, pid,status etc..

10. What is the difference between docker start and docker run?
-  docker start is used to rerun and existing container with the same name,
where as docker run is used to execute the docker image that was created with a new process name.

11. What is the difference between docker stop and docker rm?
- docker stop is to manually exit the process and exit the container where as rm is to remove the exited or unwanted containers.

12. What is the difference between docker start and docker restart?
- docker start will only re-run the existing container. whereas restart will help us to stop and re-run the container 

13. Why is it important to understand lifecycle state before debugging production containers?
-  The important state is status, for any debugging we first need to check it's state whether it is exited or running , 
secondly it would exitCode.

14. How is a container lifecycle different from a virtual machine lifecycle?
- The container life cycle is completely depend upon the main process. 
once the main process ends the container will automatically exit .
The virtual is independent of main process, if the main process finshed /exited vm is not exited. 
because the vm still contain the guest os.

15. How does this task prepare the learner for real Docker troubleshooting?
-This task making me little more confident , growing familiarity with docker commands making the learning faster and better .
