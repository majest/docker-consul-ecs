Consul ECS
==========


This image is based on the [Docker-maintained consul image](https://store.docker.com/images/fec1f6b9-0a26-49b7-990b-d001a3496cc6). It solves the problem of setting up consul servers on ECS which is a bit tricky with the AWS task definition.

### Requirements ###

* You will need AWS CLI installed or alternatively register the definitions manually.
* You will need to set up an ECS Cluster
* You will need to set a tag for the cluster's Auto Scaling Group (ASG)

### Task Definition Explanation ###

The image and task definition are constructed in a way that it could be easy to modify the parameters using env variables.

There are two task definitions, bootstrap and server which are used to set up the environment.

The [Bootstrap task definition](consul-bootstrap-definition.json) uses the environmental variable `CONSUL_PARAMS` to set the consul in bootstrap mode (useful for testing).

The [Server task definition](consul-server-definition.json) uses the environmental variable `CONSUL_PARAMS` to set the expected number of servers to 3 (feel free to change). [Consul recommends](https://www.consul.io/docs/guides/bootstrapping.html) using "3 or 5 total servers per datacenter".


There are to extra env variables that are defined when container starts. `JIP` sets the ip of the host machine that will be advertised, `JNODE` is used to set the name of the node.

Task definitions include dns server ip. Make sure it's correct for your environment. You can check that using ```ifconfig``` and comparing the ip in docker0 section on one of your ECS instances.

You can check if the nodes are registered using dig.

`dig @0.0.0.0 -p 53 INSTANCEHOSTNAME.node.consul`

### Setup ###

1. Create your cluster.
  * Make sure Auto-scaling groups are enabled as we need to tweak those later.
2. (*Optional*) Create Repository and host your own version of this docker image.
  3. If creating your own repository, modify the `image` variable in the appropriate task definition file to point to your repository.
4. Modify `__TAGKEY__` and `__TAGVALUE__` in [consul-server-definition.json](consul-server-definition.json) to values you want to use to identify these servers.
5. In the AWS Web Console, EC2 -> Auto Scaling Groups:

    Add a Tag with the key/value that you set in the task definition

6. Register Task definitions. By either:
      * On your local machine, run `register-tasks.sh` OR
      * Register tasks manually via the AWS Web Console
7. Create a service in your cluster

### Potential Problems ###

ie: Things to check first

* Do Security groups allow ingress on [the right ports](https://www.consul.io/docs/agent/options.html#ports)?
  * Specifically ensure that your servers' Security Groups are allowed, AND
  * that the consul servers' Security Group itself is allowed.
* Does your IAM role have the permission `ec2:DescribeInstances`?
  * It is recommended to create your own role/policy with only the permissions you need. However, for testing puposes **only** the policy *AmazonEC2ReadOnlyAccess* contains this permission, along with much more Read Access than you likely need.
  * More information on the Consul ec2 flags [available here](https://www.consul.io/docs/agent/options.html#_retry_join_ec2_tag_key)

### UI ###

Ui should be available at ```http://awsinstanceip:8500/ui```

Alternatively open the tunnel to the instance ```ssh -LnN 8500:localhost:8500 user@awsinstance``` so the ui can be available on your local host  ```http://localhost:8500/ui```. It's potentially useful for services development wehere you need the consul cluster available locally.
