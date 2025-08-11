## Publication of our microservice

We will create a Deployment resource that provides declarative updates for Pods along with other useful features.

#### 1. Declare a deployment

First, the Deployment declaration will be quite similar to the one of our ReplicationController.

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-deploy-nginx
spec:
```


Once it is running, we will modify the manifest in order to add a basic authentication flow. Deployments can detect changes and perform hot reloads of pods configuration.

Precisely, it must present some additional elements :

- a ConfigMap containing the file  `auth-nginx.conf` and mounted on `/etc/nginx/conf.d`
- a Secret containing the file `.htpasswd` and mounted on `/secrets`


Both ConfigMaps and Secrets store the data the same way (in key/value pairs), but ConfigMaps are meant for plain text data. Secrets values on the other hand, are `base64` encoded as they can contain binary data.

> `htpasswd -c .htpasswd alice` create a new credential file that contains the MD5 hash of alice's password.

```yaml
---
apiVersion: v1
kind: Secret
data: {}
```

<br>
Don't forget to create a service to expose your deployment inside the cluster.

> You can also scale replicas up and down in a deployment.

The application should prompt you to enter a login and password before serving the page.


#### 2. Expose your deployment

Once again, expose your deployment through a ClusterIP that makes it reachable from __inside__ the cluster.
