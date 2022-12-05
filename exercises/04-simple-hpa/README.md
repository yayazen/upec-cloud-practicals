## Scale workload to match demand


Horizontal scaling means that the response to increased load is to deploy more Pods.

#### 1. Setup a server-side web app

We will deploy a simple php webapp that performs the sum of all square roots from 0 to 100000.

Therefore, you must complete the following manifest :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-hpa-app
spec:
  replicas: 1
  template:
    metadata:
      name: simple-hpa-app
    spec:
      containers:
      - name: php-apache
        image: php:7.2-apache
```


The code is given, so you will only need to mount the following `index.php` file to `/var/www/html` as a configmap.

```php
<?php
$x = 0.0001;
for ($i = 0; $i <= 1000000; $i++) {
	$x += sqrt($x);
}
echo "OK! Sum is $x";
?>
```

This script is very simple but it can also be quite intense to compute when forked multiple times.

As usual, create a `simple-hpa-app` service and access it using port forwarding

#### 2. Set compute requirements

You will update this deployment in order to define resources requirements for each pods. They allow to both reserve and limit the amount of compute resources used by each pod.

Set the CPU capacity of each pod to always oscilate between `200m` and `500m` (in milliCpus).

> Notice that it is also possible to set memory requirements


#### 3. Increase the load 

Next, see how our deployment react to increased load. To do this, you'll start a different Pod to act as a client. The container within the client Pod runs in an infinite loop, sending queries to our application.

> Please make certain that the service `simple-hpa-app` is reachable.

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: simple-hpa-test
spec:
  restartPolicy: Never
  containers:
  - name: test
    image: busybox:latest
    command:
    - /bin/sh
    - -c
    - |
      while sleep 0.01; do
          wget -q -O- http://simple-hpa-app
      done
```

Apply this manifest with `kubectl apply -f test.yaml`.  
Within a minute or so, you should see the higher CPU load and the pod reaching its limit.

```bash
NAME                             CPU(cores)   MEMORY(bytes)   
simple-hpa-app-ff6d78d6f-x9txv   507m           34Mi  
```

You'll find that the webapp is slow or even unresponsive to requests from your browser.

#### 4. Horizontal scaling

The idea behind horizontal scaling is to create new replicas when an increased load is detected.

Create a new HorizontalPodAutoscaler that scales up to `10 replicas` while maintaining a average CPU utilization of `50%`.
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: simple-hpa-app
spec: {}
```

#### 5. Test

Run the test client again 

```bash
NAME                                                 REFERENCE                   TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/simple-hpa-app   Deployment/simple-hpa-app   183%/50%   1         10        1          2m8s
```

Here CPU usage has increased to 183% of the request. As a result, the Deployment was auto-scaled to 7 replicas.

```bash
NAME                                                 REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/simple-hpa-app   Deployment/simple-hpa-app   46%/50%   1         10        7          3m
```
