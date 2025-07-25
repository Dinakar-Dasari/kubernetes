+ The cluster (control plane + worker nodes) provides the infrastructure.
+ A Kubernetes manifest file is a YAML (or JSON) document used to declaratively define the desired state of Kubernetes resources (such as Pods, Deployments, Services, Namespaces, etc.) that the Kubernetes control plane will work to maintain.
+ values in metadata should be lowercase
+ **_ekctl is used to create cluster_**
+ **_kubectl is used to interact with cluster_**
+ We should do aws configure as we are interacting with the AWS API to create cluster
+ To create a cluster with default values. It creates,
  +  Creates both the control plane and worker nodes in a default VPC Network.
  +  Creates 2 worker nodes(m5.large) by default
  +  default AWS EKS AMI
    ```
    eksctl create cluster
  ```
+ When we give any eks config file. The it will create the cluster as defined in the file.
   ```
  eksctl create cluster --config-file=eks.yaml
   ```
  + Specify existing VPC or create new one
  + Customize node groups (worker nodes)
  + Configure networking, security groups, IAM, etc.
  + Set specific instance types, AMIs, scaling parameter
+ Delete a cluster
   ```
  eksctl delete cluster --name=<<clustername>
   ```
+ To see the worker nodes created in the cluster
     ```
    kubectl get nodes
    ```
+ To list all pods
   ```
  kubectl get pods
   ```
+ TO check on which nodes pods are running
  ```
  kubectl get pods -o wide
  ```
+ To login into the pods:
   ```
  kubectl exec -it <podname> -- bash
   ```   
+ To delete pod
   ```
  kubectl delete -f <manifest file>
   ``` 
+ To debug pods use **_describe_** option:
  + To show all pods:\
          ```
        kubectl describe pods
          ```
  + To show certain pod:
      ```
    kubectl describe pod <pod-name>
      ```
  + To list all the services
     ```
    kubectl get svc /services
     ```   
  + To see the details about a service, like endpoint(to which pods), ip of service..etc
     ```
    kubectl describe svc <name of service>
     ```
  + command to see the replica sets
     ```
     kubectl get rs
    ```
  + command for deployments history
    ```
    kubectl rollout history deployment/<name of deployment>
    ```   
  +  Rollback a previous deployment
      ```
     kubectl rollout undo deployment/<deployment name>
     ```
