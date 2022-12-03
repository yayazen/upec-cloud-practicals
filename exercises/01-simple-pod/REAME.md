## A simple web microservice
---

You will manipulate pods and configmaps to deploy your first microservice.


### 1. Pod declaration

1. Create a Pod with a nginx container and an empty volume attached to `/usr/share/nginx/html`.  
Have a look to ```bash pod.spec.volumes.emptyDir```


```yaml
# To create: kubectl apply -f pod.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  labels:
    exo: simple-pod
spec:
  volumes:
  - emptyDir: {}
    name: html
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
      protocol: TCP
    volumeMounts:
    - name: index
      mountPath: /usr/share/nginx/html

```


After the pod's creation, you can review its description and various informations

```bash
# Get 
kubectl describe pod/simple-pod 
# 
```

You c

>   By default, the nginx service is listening on port 80. You can access it by forwarding the pod's port to your local [http://127.0.0.1:8080](http://127.0.0.1:8080) <br>
> > `kubectl port-forward pod/simple-pod 8080:80`

<br>

3. The web page should show a `403 error`. Update its content by uploading the `index.html` file to the volume path.

>  <font size=3>`kubectl cp -h`</font>

<br>

The page should now display correctly. However while its okay to use `cp` for large files, changes won't persist after the pod's lifetime.


### 2. Storing configuration data

We will create a ConfigMap holding the web content for our pod. 
 
Either by using the CLI with 
   - `kubectl create cm`  

Or by adjusting the following manifest

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: simple-pod-html
data: {}

```


2. Modify the pod declaration in order to mount this ConfigMap at `/usr/share/nginx/html`.

When recreating the pod, the page should now display correctly.