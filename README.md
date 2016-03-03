Consul ECS
==========


This image is based on https://github.com/gliderlabs/docker-consul. It solves the problem of setting up consul servers on ECS which is a bit tricky with the AWS task definition.

### Requirements ###

* You will need AWS CLI installed or alternatively register the definitions manually.
* You will need to set up an internal load balancer in AWS

### Setup ###

The image and task definition are constructed in a way that it could be easy to modify the parameters using env variables.

There are two task definitions, bootstrap and server which are used to set up the environment. Bootstrap has an extra variable (CONSUL_PARAMS) that sets the consul in bootstrap mode. Server task definition uses the same environmental variable to pass the information about the internal load balancer.

Load Balancer is required so that we know to which node we can connect initially. It needs to listen on ports 8301 and 8500. Replace __INTERNALELB__ in consul-server-definition.json with the hostname of your internal load balancer

There are to extra env variables that are defined when container starts. JIP sets the ip of the host machine that will be advertised, JNODE is used to set the name of the node.

Task definitions include dns server ip. Make sure it's correct for your environment. You can check that using ```ifconfig``` and comparing the ip in docker0 section on one of your ECS instances.

You can check if the nodes are registered using dig.

```dig @0.0.0.0 -p 53 INSTANCEHOSTNAME.node.consul```


### UI ###

Ui should be available at ```http://awsinstanceip:8500/ui``` 

Alternatively open the tunnel to the instance ```ssh -LnN 8500:localhost:8500 user@awsinstance``` so the ui can be available on your local host  ```http://localhost:8500/ui```. It's potentially useful for services development wehere you need the consul cluster available locally.

