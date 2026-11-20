## Mandatory question and Answers Task 1.6

1. What is a Docker image layer?
- The doker is running each command in the dockerfile in an order , so the each line of execution can be considered as a layer.
  if the middle layer changes the docker we re-run the coming execution it will not take from the cache

2. How does Docker decide whether a cached step can be reused?
- If the file is not having any chandes in that compared to the file in the cache then they will take the same data from the cache. 
  or else if they found any changes they will surely re run .

3. Why was the second build faster when nothing changed?
-  The file was collected from the cache so the docker doesn't needed to execute those any files which causes the fast.

4. Why did changing app.py rebuild fewer layers than changing requirements.txt?
-  The app.py was at the bottom level , no much files also not depending up on it. here it shows the order matters, so we need to arrange the according dependency and chances of frequent changes.

5. Why does changing one step often cause later steps to rebuild too?
-  Docker finds some thing is changed. So the next steps are taken from the cache instead they re run until the last step.
   They are working like a chain called layers so if one file changed that file and below file needed to execute again.

6. Why does Docker process the Dockerfile top to bottom?
-   top to bottom order is necessary to maintain the docker build-cache mechanism.
   One file is depending on the above file.
   if changes detected the below files need to re execute 

7. Why is requirements.txt usually copied before application source files?
-  The order of docker file matters we should set the frequent changing application in the bottom
   we should look for the dependency of the file, one file's result may be needed for the next file 
   so based on these we conifgure the order

8. Why should frequently changing files usually be copied later in the Dockerfile?
-  If frequent files kept top the files after it would unwnatedly re execute without having any changes and causes the heavy load to function
   
9. What does docker history help you understand?
   -so the Workdir is placed bottom becuase it is not re executed frequently where as the app file is in the top which is undergone frequent changes
   which shows that only frequent changes files are rebuilded 

10. How does Docker build cache help in CI/CD pipelines?
- instead of running the whole source code file it takes the unchanged data layer from the cache which saves a lot of time ,memory and computatioal power.
	
11. Why does Dockerfile instruction order matter in production?
- In production, Dockerfile instruction order matters because it directly affects build time, cache reuse, and deployment efficiency.

12. How does this task prepare the learner for later image optimization work?
- From this task I came to know the layers of docker , docker taking data from the cache which saves a lot of time.
  the importance of order in the docker file , the frequent changing file should kept in bottom etc..

