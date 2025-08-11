## Resiliency of pods


#### 1. Simulate a node failure

A pod is the smallest unit of compute in kubernetes. It is tied to a single node runtime and does not come with a lot of workload logic.

To ensure that controle plan no schedule pod run this command
```bash
kubectl taint node/k3d-upec-server-0 node-role.kubernetes.io/master:NoSchedule
```


This command prints the node running our simple-pod.

```bash
kubectl get pod/simple-pod-nginx -o jsonpath='{.spec.nodeName}{"\n"}'
```

<br>
We will observe the behaviour of this pod in the event of a node failure.

1. Stop the node where the pod is running with  `docker stop <node>`

2. Check the state of the pod. Is it still running ?  

> Don't forget to run `docker start <node>` before pursuing.


#### 2. Create replicas

A naive solution to this problem is to create replicas of this pod spread across multiple nodes.

You will create a `ReplicationController` resource that adds workload logic to our application by maintaining 3 replicas of our pod.

> The `spec.template` object describes the pod that will be created in the case of insufficient replicas. It is the same as the pod declaration.  

```yaml
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: simple-rc-nginx
spec: {}
```

> Be careful in the usage of labels with selectors. Read the documentation.

<br>
As usual, you can monitor the state of the controller and the numbers of ready replicas.

```bash
kubectl get rc/simple-rc-nginx
NAME              DESIRED   CURRENT   READY   AGE
simple-rc-nginx   3         3         3       21s
```

<br>
If you delete one pod, the controller should detect it and schedule a new pod to replace it.

<br>

Additionally you can scale replicas up and down, either by modifying the resource/manifest or with kubectl.
```bash
kubectl scale --replicas=5 rc/simple-rc-nginx
```

#### 3. Create a service

Port forwarding to a pod is not very convenient with multiple replicas. Ideally we need a way to address them in a load balanced manner.
A `Service` resource is the standard way of exposing an application inside the cluster. It uses selectors to distribute traffic amongst selected pods.

Create a `svc.spec.type.clusterIP` service to expose the replicas inside the cluster.

> You should consider using labelled selectors as you did for the RC.
	
```yaml
apiVersion: v1
kind: Service
metadata:
  name: simple-rc-nginx
spec: {}
```


You can then access this service through a forwarded port.

```bash
kubectl port-forward svc/simple-rc-nginx 8080:80
```
