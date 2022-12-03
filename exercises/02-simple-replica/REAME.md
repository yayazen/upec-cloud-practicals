## Node failure

We can easily observe the behavior of Pod resources in the event of a node failure.

1. Stop the node hosting our `simple-pod` with `docker kill k3d-upec-<node>`

2. Check the state of the pod with `kubectl describe pod/simple-pod`

> <font size=3> Don't forget to restart the node before pursuing. </font>


##