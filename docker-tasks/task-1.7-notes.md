## Mandatory questions and Answers 1.7
 
1. Why are Docker containers stateless by default?
- containers are made dispossible so that you can run your application exiting while the process ends.
  according to the container life cycle they can't able to persist the data.

2. What is a Docker volume?
-  The container is stateless but the data shouldn't so we store those persist in docker volume, 
   which is a docker managed volumes and stored seperately from container's layer.

3. How is a Docker volume different from normal container storage?
-  The normal container can't able to persist the data. due to they are made dispossible once the main process ends the container also exited.
   where as docker volume is a persist storage which can sustain even after the container exit.

4. Why does MySQL need persistent storage?
-  Mysql is a database files, indexes metadata on the disk, which should be sustained even after the container exit.

5. What does -v mysql-data:/var/lib/mysql mean?
- -v <volume> :<container_path>
   It means mount the docker volume on to the specific file path  inside the container.

6. What is the purpose of docker volume create?
-  It explicitly creates a named Docker volume.so you have a persistant object that can be managed independently and attached to the container.

7. What is the purpose of docker volume inspect?
-  It gives meta data of the volume ,created at, name, mountpoint, labels.

8. What did docker inspect show about the MySQL container's mounts?
-  "/var/lib/docker/volumes/mysql-data/_data",
   it shows the path where the data is stored inside in the container.

9. Why did the data survive after the first container was deleted?
-  The data is made persistant with docker volumes so the new container which uses the mysql-data or fetch the existing data .

10. What is the difference between deleting a container and deleting a volume?
-  deleting a contatiner only deletes the container and volume persist, we can re -run the container or start a new container with the same old data.
   where as deleting a volume means deleting whole data, the data will be lost.

11. Why is it dangerous to run databases in containers without persistent storage?
- when the containers crashed or stopped the  entire data is lost. so we need to be backed up with storage like  docker volume.|

12. Why was it helpful to use docker exec in this task?
-  docker help us to start a new shell process for connecting the mysql client and we doesn't need to use port for communicating with container's internal communcation facility.

13. What did docker stats and docker top show you?
-  docker stats shows the statistics of containers like cpu usage, memory usage, network i/o etc..
- docker top is for showing the process that running inside a container.

4. How does this task prepare the learner for Docker Compose and Kubernetes storage later?
-  The important concept is that storage should have a lifecycle independent of the application container.

15. What would happen if the volume was removed after the task?
- The  entire data that stored inside in the volume will be removed.
