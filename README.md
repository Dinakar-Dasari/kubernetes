**Kubernetes Pod Phases:**  
  + **Pending**: Pod has been accepted by the Kubernetes system but has not yet started running. It may be waiting for scheduling or image pulling.
  + **Running**: At least one container in the pod is running or is in the process of starting or restarting.
  + **Succeeded**: All containers in the pod have successfully completed, and the pod will not be restarted.
  + **Failed**: One or more containers terminated with an error, and the pod will not be restarted.
  + **Unknown**: The state of the pod cannot be determined, usually due to communication issues with the node.
    
**Common Kubernetes Error Messages:**
  + **CrashLoopBackOff**: A container repeatedly crashes and Kubernetes backs off restarting it.
  + **ImagePullBackOff / ErrImagePull:** Kubernetes cannot pull the container image due to incorrect image name, tag, or authentication issues.
  + **CreateContainerConfigError**: Container configuration errors, such as invalid environment variables or volume mounts.
  + **OOMKilled**: Container terminated by the Out of Memory Killer for exceeding memory limits
    
**Container states:**
  + There are three possible container states: **Waiting, Running, and Terminated.**
  + To check the state of a Pod's containers, you can use `kubectl describe pod <name-of-pod>`

**restartPolicy:**
  + restarts are container-level, but controlled at the pod-level.
  + The pod-level restartPolicy is specified under `spec.restartPolicy` in the pod manifest.
  + when one container in a pod fails, only that container restarts, not the entire pod.
  + `restartPolicy: Always | OnFailure | Never`
    | **restartPolicy**                                           | **What happens when a container exits/fails**                                                    |
    | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
    | `Always` (default for Deployments, ReplicaSets, DaemonSets) | The container is **always restarted**, no matter what exit code it returned.                     |
    | `OnFailure`                                                 | The container is **restarted only if** it exited with a **non-zero** exit code (i.e., an error). |
    | `Never`                                                     | The container is **never restarted**, even if it crashes.                                        | 
  + ```
    kind: Pod
    metadata:
      name: print-envars-greeting
      labels:
        app: pod
    spec:
      containers:
        - name: print-env-container
          image: bash:latest  
      restartPolicy: Never
    ```
  **imagePullPolicy**
  + Kubernetes determines when the kubelet (container runtime) should pull a container image from the registry before starting a container
  + **Always**: Kubernetes always pulls the image from the registry (even if it’s already cached locally), ensuring the latest version is always used.
  + **IfNotPresent**: Kubernetes only pulls the image if it’s not already present on the node locally.
  + **Never**: Kubernetes never pulls the image from the registry. It will only use a local image if present; otherwise, the pod will fail to start.

+ The cluster (control plane + worker nodes) provides the infrastructure.
+ A Kubernetes manifest file is a YAML (or JSON) document used to declaratively define the desired state of Kubernetes resources (such as Pods, Deployments, Services, Namespaces, etc.) that the Kubernetes control plane will work to maintain.
+ values in metadata should be lowercase
+ **kubens, the CLI tool that makes switching Kubernetes namespaces**
  + Switch to a namespace (e.g., roboshop):--> `kubens roboshop`
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
+ To know what is the apiVersion for a resource--> `kubectl api-resources`
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
+ To edit a Kubernetes resource (like pods, deployments, services, etc.) in your default editor (e.g., vi, nano)
  ```
   kubectl edit <resource> <name>
  ```
+ To check on which nodes pods are running
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
  + Create a Deployment
     ```
     kubectl apply -f manifest.yaml
    ```
  + To see the deploments
    ```
    kubectl get deployments
    ```
  + Updating a Deployment
    + Either update the yaml file and give apply command or
    + give command
      ```
      kubectl set image deployment/nginx-deployment nginx=nginx:1.18
      ```
  + To see the Deployment rollout status
    ```
    kubectl rollout status deployment/<name of deployment>
    ```  
  + command for deployments history
    ```
    kubectl rollout history deployment/<name of deployment>
    ```   
  + Rollback a previous deployment
      ```
     kubectl rollout undo deployment/<deployment name>
     ```
     you can rollback to a specific revision by specifying it with --to-revision
     
     ```
     kubectl rollout undo deployment/<deployment name> --to-revision=2
     ```
+  pause a rollout 
    ```
   kubectl rollout pause deployment/nginx-deployment
    ```
+ When you have multiple clusters and wanted to switch to a specific cluster then
   ```
   kubectl config use-context <clustername>
  ```
  + If you’re working with multiple clusters (e.g., dev, staging, prod), all their connection info is stored in your kubeconfig file (usually ~/.kube/config)
  + `kubectl config get-contexts` --> List all available contexts
    
   ```
       NAME        CLUSTER     AUTHINFO    NAMESPACE
        dev-cluster  dev         dev-user    
        prod-cluster prod       admin-user
   ```
   
  + To copy files between your local machine (jump host) and a container inside a Kubernetes Pod.  
      `kubectl cp -c nginx-container index.php nginx-phpfpm:/usr/share/nginx/html/index.php`
      + `-c nginx-container` --> This flag specifies which container inside the Pod you want to copy the file to.
      + `nginx-phpfpm` → the name of the Pod
  + If some pods are running already and no manifest file exists then to get the manifest file,  
     `kubectl get pod <pod_name> -o yaml  > manifest.yaml`
   
