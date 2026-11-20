Task 1.3 notes

1. What is a Dockerfile?
  - A Dockerfile is a text file that contains the instructions to build  a docker image,
  - It has a specific keywords like from ,workdir,,run ,env
   
2. Why is a Dockerfile required when packaging an application into an image?
  - Instead of configuring the server manually we use dockerfile to which tells docker what operating system to use, what dependencies to install.
 it is like a blueprint.which we only need to configure it once.
 
3.What does docker build do?
  -docker build will execute the docker file. Instead of configuring the environment manually, we use a Dockerfile to tell Docker what to include and how to build the image. It is like a blueprint that we configure once and reuse.

4. What does docker run do?
- docker create a new container from an image and start it. where you can run in detach mode ,
  we can give name for container.It can also configure things like ports, environment variables, and volumes.


5. What is the purpose of requirements.txt in this task?
- The requirements contains the Python packages and their versions that the application needs.
 Docker uses it to install the required dependencies while building the image.

6. Why must the Flask app bind to 0.0.0.0 inside the container?
- 0.0.0.0 makes Flask listen on all network interfaces inside the container. 
This allows requests coming through Docker's port mapping to reach the Flask application.

7. What does -p 5000:5000 mean?
- It maps port 5000 on the host machine to port 5000 inside the container. So when you access port 5000 on your computer,
 Docker forwards the request to the Flask app inside the container.

8. What is the purpose of WORKDIR in the Dockerfile?
-WORKDIR sets the working directory inside the Docker image and container.
 It also makes commands like COPY, RUN, and CMD work relative to that directory.

9. What is the difference between RUN and CMD in the Dockerfile?
- RUN executes commands while building the image, such as installing dependencies.
 CMD specifies the default command that runs when a container starts.

10. Which project files are included in the Docker image?
-The files included depend on the COPY instructions in the Dockerfile.
 In this task, files such as app.py and requirements.txt are copied into the image.

11. What is the purpose of docker logs in this task?
-docker logs shows the output produced by the container's main process.
 It is useful for checking application output and finding errors when the Flask container fails or exits.

12. What is the purpose of docker inspect in this task?
docker inspect shows detailed information about a Docker container or image.
 It can be used to check configuration such as networking, ports, environment variables, and container state.

13. What is the purpose of docker exec in this task?
docker exec allows us to execute a command inside a running container.
 It is useful for inspecting files or checking the environment inside the container.

14. Why did the Flask container stay running?
-The container stays running because its main process is the Flask application,
 and the Flask server keeps running while waiting for requests. When that process stops, the container also stops.

15. Why does removing the container not remove the image?
-A container is a runtime instance created from an image, while the image is the packaged template.

 Removing the container does not remove the image because the same image can be used to create other containers.
16. How does this task prepare the learner for production container workflows?
-It teaches the basic workflow of building images, running containers, mapping ports, checking logs, and inspecting or accessing containers.
 These are fundamental skills used when deploying and troubleshooting containerized applications in real environments.

