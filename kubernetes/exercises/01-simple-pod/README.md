 ## A simple web application

You will manipulate pods and configmaps in order to deploy a microservice in kubernetes.


#### 1. Declare a pod

Complete the following Pod manifest in order to deploy an nginx container with an empty volume attached to  
`/usr/share/nginx/html`.  

```yaml
# To create: kubectl apply -f pod.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod-nginx
  labels:
    exo: simple-pod
spec:
  volumes:
  - emptyDir: {}
    name: html
  containers: {} # TODO
```

<br> 
You can review the results through various kubectl commands.  

```bash
# Describe resources and show event logs from Kubernetes controllers
kubectl describe pod/simple-pod-nginx

# Get brief of a pod
kubectl get pod/simple-pod-nginx

# Get brief of resources filtered by label in the yaml format
kubectl get all -l "exo=simple-pod" -o yaml

# Get a specific field value from a resource (here the pod's IP)
kubectl get pod/simple-pod-nginx -o jsonpath='{.status.podIP}'
```

You can also print the logs from the containered application.
```bash
kubectl logs pod/simple-pod-nginx
```

#### 2. Acces the nginx service 
By default, the nginx service is listening on port 80. If not already done, you should expose the container port in the pod declaration (see `pod.spec.containers.ports`).

Then it can be accessed by forwarding your [localhost:8080](http://127.0.0.1:8080) to the pod's port.
```bash
kubectl port-forward pod/simple-pod 8080:80
```
<br>

Surprisingly, the web page shows an error 403.
> Can you hypothesize on why it occurred ? Maybe using the application logs.

<br>

However we notice that the pod is in a ready state and contradicts the real state of our application.
```bash
NAME                   READY   STATUS    RESTARTS   AGE
pod/simple-pod-nginx   1/1     Running   0          1m
```

#### 3. Evaluate the readiness of a container

Try to add a `readinessProbe` to your container definition that leaves the pod in an unready state until the web page is answering with a 200 response code.

#### 4. Fix the web page

You should update the web content by uploading the `index.html` to the container web root.
> `kubectl cp` can be quite handy

The page should now display correctly and the pod should hop in a ready state. However while its okay to use `cp` in some cases, here changes won't persist after the pod's lifetime.


#### 5. Storing configuration data

A ConfigMap is a very handy resource that can hold configuration data for an application.
 
You can use the CLI and `kubectl create` to generate the configuration from the index.html file.  

Also you can choose to adjust the following manifest :

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: simple-pod-html
data: {}

```

Finaly modify the pod declaration in order to mount this configmap at `/usr/share/nginx/html`.

The application should serve its html content from the configmap and it will allow the configuration to survive reboots.
