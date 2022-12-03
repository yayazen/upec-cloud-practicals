## A simple web microservice

You will manipulate your first kubernetes resources to deploy a microservice.


#### 1. Declare a pod

The following Pod must contain an nginx container with an empty volume attached to `/usr/share/nginx/html`.  

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

You can review the results through various kubectl commands. 

```bash
# Describe resources and show event logs from Kubernetes controllers
kubectl describe pod/simple-pod-nginx
# Get brief of a pod
kubectl get pod/simple-pod-nginx
# Get brief of multiple resources filtered by label in yaml
kubectl get all -l "exo=simple-pod" -o yaml
# Get a specific field value from a resource (here the pod's IP)
kubectl get pod/simple-pod-nginx -o jsonpath='{.status.podIP}'
```

And get the logs from the containered application once its running.
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
> Can you hypothesize on why it occured ? Maybe using the application logs.

<br>

However we notice that the pod is in a ready state thus in contradiction with the application state.
```bash
NAME                   READY   STATUS    RESTARTS   AGE
pod/simple-pod-nginx   1/1     Running   0          1m
```

#### 3. Evaluate the readiness of a container

Try to add a `readinessProbe` to your container definition that leaves the pod in an unready state until the web page is ready.

#### 4. Fix the web page

You should update the web content by uploading the `index.html` to the container web root.
> `kubectl cp` can be handy

The page should now display correctly and the pod should hop in a ready state. However while its okay to use `cp` in some cases, here changes won't persist after the pod's lifetime.


#### 5. Storing configuration data

A ConfigMap is a very handy resource that can hold configuration data for an application.
 
You can use the CLI and `kubectl create` to generate the configuration from the index.html file.  

Or choose to adjust the following manifest

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: simple-pod-html
data: {}

```

Finaly modify the pod declaration in order to mount this ConfigMap at `/usr/share/nginx/html`.

The application shoud serve our html files from now on and it will survive reboot.
