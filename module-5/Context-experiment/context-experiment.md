Experiment: Testing context of AI

I tried adding the error log lines in start , middle and end 
I tried in claudd free version and chatgpt's free version
I create around 4000 lines  with the below command
for i in $(seq 1 4000); do echo "2026-11-02T09:00:00Z app[12]: request ok id=$i latency=$((i % 90))ms"; done > noise.log

Observation : 
Model 1 : Chatgpt 
it took around 19 sec for finding the error log from end 

it took around 18 sec for finding the error log from middle

- I noticed it gave me an option to choose which response from 2 options where there is no difference in the 2 response

Model 2 : claude sonnet 5.5
- it gave me fast repsonse and correct answer 

