## Scale workload to match demand


Horizontal scaling means that the response to increased load is to deploy more Pods.

#### 1. Resources requirements

First, we will update our deployment in order to define CPU requirements for each pods. They allow to both reserve and limit the amount of compute resources used by each pod.

Set the correct values so that each pod c i always between `200m` and `500m` 

> It is also possible to set RAM requirements


#### 2. Increasing the load


This 


