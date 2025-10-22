**_Why Volumes?_**
+ By default containers data is stored in the container. When the container is terminated or deleted all the data is lost.
+ For that purpose volumes concept is introduced. Kubernetes provides two main types of volumes: **Ephemeral Volumes and Persistent Volumes.**
+ **Ephemeral volumes:**
  + ephemeral volumes have the same lifecycle as the pod itself. Once the pod dies, the data is also lost.
  + The primary use cases are sharing data between containers and ensuring data survives container restarts within the same Pod.
  + when the Pod is created, the ephemeral volumes are created, and when the Pod is deleted, the volumes are deleted along with the Pod. We define them in `Volumes` field.
  + We use the `volumeMounts` field within each container spec to mount a defined volume into one or more containers in the same Pod. Multiple containers in a Pod can mount the same ephemeral volume to share data during the Pod’s lifetime.
  + Ephemeral volumes types include emptyDir (a blank directory initially), configMap, secret, downwardAPI, and CSI ephemeral volumes provided by certain storage drivers.
  + **emptyDir:**
   + Emptydir volume is intially empty.
   + It's created when the pod is created.
   + The volume is shared between all the containers in the pod.
   + Data survives container restarts but not pod deletion.
   + How emptyDir volume is attached:
   + Two cases :
     + **Default (emptyDir without medium: Memory)**
       + Stored on the node’s disk (HDD or SSD).
       + Size is limited by the node’s available storage.
     + **emptyDir.medium: Memory**
       + Stored in RAM via a tmpfs mount.
       + Faster read/write, but volatile and limited by available node memory.  
  + They are ideal for applications where the data is temporary or configuration-related (often stateless).
  + The storage is actually provisioned on the Node where the Pod is running. When the pod is deleted, Kubernetes cleans up that directory, removing the data.
+ **Persistent Volumes:**
  + Persistent Volume on the other hand can store the data far beyond the pod’s lifecycle. The data is available even after the pod is destroyed, and can be accessed by newer pods as well.
  + Persistent Volumes abstract cloud-provider specific storage (like AWS EBS, Google Persistent Disk, Azure Disk, NFS, etc.)
  + A PV is a cluster resource, created manually by administrators or provisioned dynamically through a StorageClass.
  + Each PV has details such as: capacity (e.g., 10Gi), access modes (ReadWriteOnce, ReadWriteMany) & reclaim policy (Retain, Recycle, Delete
  + Every Persistent Volume has a reclaim policy that defines what should happen to the volume after the pod is destroyed.
    + **Retain**: The persistent volume will still exist after the pod is deleted. It will retain the data of the pod,
    + **Recycle**: Recycle automatically cleans the Persistent volume. It simply runs a simple rm -rf /volume-mount-path/*. Once the data has been deleted, the volume can be bound to a new pod.
    + **Delete**: The delete reclaim policy will delete the persistent volume. 
  + A **Persistent Volume Claim (PVC)** is a user or Pod-level request for storage,
  + A PVC specifies storage size, access mode, and optionally a StorageClass.
  + Kubernetes binds the PVC to a PV that satisfies its requirements.
  + Once bound, Pods can mount this claim as a volume and use it seamlessly
  + There are two ways PVs are provisioned:
    + Static provisioning: Administrators create PVs manually before use.
    + Dynamic provisioning: Kubernetes automatically creates PVs matching PVC requests using StorageClasses.
+ A `hostPath` volume mounts a file or directory from the host Node's filesystem directly into a Pod's container.
  + The data persists after the Pod is deleted, but the Pod loses access to the data if it is rescheduled to a different Node.
  + hostPath should not be considered a true Persistent Volume — it behaves more like an ephemeral volume with node-level persistence
  + hostPath is discouraged for production — it ties pods to specific nodes and breaks Kubernetes’ portability and scheduling flexibility. It’s mostly used for testing, debugging, or system-level daemons like monitoring agents.
  + Since, host path is mounted there are security concerns. So we should try to avoid using them
  + We should provide readonly access.
  + Generally we use in daemonsets.
+ **Without StorageClass → PVs must exist beforehand (static provisioning).**
+ **With StorageClass → PVC can trigger dynamic provisioning. Kubernetes will ask the underlying cloud/storage system to create a PV automatically that matches the PVC request.** 
+  PV --> cluster level
+  PVC --> Name Space level
+  storageclass --> cluster level
+  EKS admins control cluster level objects(PV).
+  As a roboshop devops engineer, you need a disk to be created for your application,
+  we will raise a ticket for this. 5 GB, filesystem type(ext4), etc..it is approved by roboshop team lead/delivery lead. Storage team also checks this and it is approved their team leader.
+  then storage team creates the disk.
+  provide these disk details to EKS admin, then they create PV for us and tell us the name.
+  EBS size is fixed, EFS is elastic it automatically grows upto 48TB.
+  EBS will not have any SG attached, but EFS is in network, so there will be SG attached and 2049 should be allowed.
+  Refer `session-62` notes for EBS/EFS volume setup
-----


+ Kubernetes pods are ephemeral. When a pod processes data and is eventually deleted, any data stored within it is lost unless a volume is attached. Volumes in Kubernetes ensure that essential data remains available even after a pod’s lifecycle ends.
+ For **single node:**
  + we use a directory on the host as our storage medium. Pod in that node writes data to the /app directory in the node.
  + Even if the pods restarts it will be created in that Node and it will read the previous data from that host path
  + But, this is not the case in Multi Node.
+ **Multi-Node:**
  + If one pod writes data to /data on Node A, and then the pod is moved to Node B, does /data on Node B have the same data. It's not. So, there is inconsistent data storage.
  + Volumes should be outside of the cluster (Like AWS)
  + Which is not recommended for stateful app (like data bases)
  + So, to achieve consistent and shared storage across nodes, an external, replicated storage solution should be used.
  + External storage options like Network File System (NFS), EBS(public cloud storage)
    | Storage                                  | Description                                                          |
    | ---------------------------------------- | -------------------------------------------------------------------- |
    | **hostPath**                             | Just a local folder on a node (⚠️ works only for single-node setups) |
    | **EBS (Elastic Block Store)**            | AWS-managed disk attached to a VM, good for databases                |
    | **NFS (Network File System)**            | Shared disk usable by multiple pods across nodes                     |
    | **GCEPersistentDisk / AzureDisk / etc.** | Platform-specific block storage                                      |
  + So, Kubernetes solves the problem of tight coupling of storage and pod by storing the data outside of the node and pods.
  + **_EBS (Elastic Block Store) is block storage from AWS._**
    + It acts like a hard disk.
    + data transfer is very fast.
    + should be as near as possible to the system/server(should be in Same Availability zone)
    + Can be used only by one node at a time (ReadWriteOnce).
    + Good for databases, etc.
    + Example: Hard-disk
  + **_NFS (Network File System) is a file-sharing protocol._**
    + Can be used by multiple pods across nodes.
    + can be anywhere in the internet
    + data transfer is slow compared to HD
    + Good for shared content like images, logs.
    + Example: Google Drive
  + **_Persistent Volume (PV):_**
    + Think of it like a virtual hard disk(SDD, HDD).
    + It's managed by Kubernetes at the cluster level.
    + It is created by admins manually in YAML or automatically using StorageClasses for dynamic provisioning.
    + This PV consists of stoarges like NFS, EBS, etc.
    + Think PV as a representation of an external storage resource (like EBS, NFS, etc.) in the Kubernetes world.
    + PVs are cluster-wide resources, not bound to a particular node, which means they can be mounted from any node
    + PV have multiple spec like Access Modes, Capacity & Volume Type.
      + **_Access modes_** determines how a volume can be mounted (e.g., ReadOnlyMany, ReadWriteOnce, ReadWriteMany).
        + Like, How the volume is accessed
          | Mode                    | Description                                           |
          | ----------------------- | ----------------------------------------------------- |
          | **ReadWriteOnce (RWO)** | The volume can be mounted as read-write by only one node.(Like USB, at a time can be connected to only one device)                               |
          | **ReadOnlyMany (ROX)**  | The volume can be mounted as read-only by many nodes.                              |
          | **ReadWriteMany (RWX)** | The volume can be mounted as read-write by many nodes. (good for shared workloads) |
          | **ReadWriteOncePod (RWOP)** | - single Pod, read-write                          |
      + **_Capacity:_** Specifies the allocated storage size (1Gi in this example).
      + **_Volume Type:_** Here, we use a host path to utilize local node storage.
        +  HostPath is useful for demonstration purposes,it is not recommended for production environments
      +  **EBS (Elastic Block Store):**
        +  Supports RWO (ReadWriteOnce)
        +  Can only be attached to one EC2 instance at a time (so one node in Kubernetes).
        +  Great for single-node persistent storage needs.
      +  **EFS (Elastic File System):**
        +  Supports RWX (ReadWriteMany) and ROX (ReadOnlyMany)
        +  Can be mounted simultaneously by multiple nodes
        +  Great for shared storage across multiple Pods in a microservices setup.
       
  + **_Persistent Volume Claims(PVC):_**
    + Kubernetes administrators are responsible for creating PVs, while users create PVCs to request and utilize that storage.
    + It's like storage is available in PV, but to use we need to request through PVC.
      + _"Hey Kubernetes, I need 5Gi of storage with read-write access."_
    + Once a PVC is defined, Kubernetes automatically binds it to an available PV that meets specific criteria such as capacity, access modes, volume modes(Filesystem or Block device), storage class, and additional parameters.
      + _"Kubernetes then looks for a matching PV that satisfies that claim."_ 
    + Each PVC is exclusively bound to a single PV.
    + If no matching volume exists at the time of creation, the PVC remains in a pending state until a compatible PV becomes available.
    + **Deleting a Persistent Volume Claim:** By default, deleting a PVC does not automatically remove the associated PV. The behavior of the PV is dictated by its reclaim policy. Kubernetes supports three common reclaim policies:
        | Policy    | What happens to the PV        | Use case          |
        | --------- | ----------------------------- | ----------------- |
        | `Delete`  | Delete the storage(PV also got deleted)            | Non-critical data |
        | `Retain`  | Keep the storage/data(PV is present)         | Databases, logs   |
        | `Recycle`(deprecated) | Obsolete, use only for legacy |                   |
    + Choosing the correct reclaim policy is essential for managing your Kubernetes storage lifecycle effectively. It allows you to determine whether the storage resource should persist after the PVC's deletion or if it should be removed automatically.
    + **_Pod lifecycle vs PVC vs PV_**
      + If Pod dies ➝ Volume untouched, new pod can still use it.
      + If PVC is deleted ➝ K8s checks ReclaimPolicy to decide PV fate.
      + If ReclaimPolicy is Delete ➝ PV and data gone.
      + If ReclaimPolicy is Retain ➝ PV and data remain (need manual cleanup/reclaiming).
        | Event                            | PVC Exists? | PV Exists?   | Underlying Storage (EBS/NFS) | Notes                 |
        | -------------------------------- | ----------- | ------------ | ---------------------------- | --------------------- |
        | Pod deleted                      | ✅           | ✅            | ✅                            | No change             |
        | PVC deleted + `Retain`           | ❌           | ✅ (Released) | ✅                            | Manual cleanup needed |
        | PVC deleted + `Delete`           | ❌           | ❌            | ❌                            | Fully cleaned up      |
        | PVC deleted + `Recycle` (legacy) | ❌           | ✅ (Reused)   | ✅ (wiped)                    | Not used today        |
  + **_Storage Class:_**
    +  Earlier, we had to manually define PVs first. But that’s not scalable.
    +  Define a template for how PVs should be dynamically provisioned
    +  Instead of manually creating PVs, you use a storage class that defines a provisioner (like EBS Cloud's persistent disk provisioner) to automatically create and attach a disk when a claim is made.
    +  We define a StorageClass, which acts like a template: "If a PVC is created and no PV exists, auto-create a PV using this class (e.g., using EBS)"
      + Key fields in a StorageClass:
        + Provisioner: What backend to use (e.g., ebs.csi.aws.com)
        + ReclaimPolicy: What to do when PVC is deleted
  + You're deploying MySQL in Kubernetes.
  +   You:
    +   Create a PVC for 10Gi of storage and mention storage class name.
    +   There will a yaml file with the storage class name with kind storage.
    +   It uses a StorageClass backed by AWS EBS (or) if created manually then it refers that PV.
    +   Kubernetes creates a new EBS disk.
    +   Pod uses the PVC → writes data to the EBS disk.
    +   Pod dies? Data still there. Pod moves? Data is reattached.
 
**How it works (flow):**
 + Developer creates a PVC and specifies storageClassName: fast-ssd
 + Kubernetes looks for a StorageClass named fast-ssd yaml file.
   + PVC has a storageClassName, Kubernetes directly asks the provisioner in that StorageClass to create a new PV. 
 + The StorageClass contains a provisioner (like kubernetes.io/aws-ebs or kubernetes.io/gce-pd) and parameters (e.g., disk type = gp2).
 + Kubernetes contacts the provisioner → creates a new volume on the cloud{aws) → automatically creates a PV → binds it to the PVC.
 + The user will mention the PVC Name in the deployment file
 + `PVC created → Kubernetes sees storageClassName → calls provisioner → provisioner creates volume → new PV object is created → PVC binds to that PV.`

 + In Kubernetes, dynamic volume provisioning happens through a StorageClass.
 + When a PersistentVolumeClaim (PVC) is created that refers to a StorageClass,
   + Kubernetes talks to the provisioner (e.g., EBS, EFS, etc.)
   + and automatically provisions storage in the cloud.
 + Case 1: EBS (Amazon Elastic Block Store)
   + The EBS CSI driver acts as the provisioner.
   + When you create a PVC referring to that StorageClass:
     + A new EBS volume is dynamically created in AWS.
     + It’s then attached to the EC2 node where the Pod runs.
     + Access mode: typically RWO (ReadWriteOnce).
   + Case 2: EFS (Amazon Elastic File System)
     + The EFS file system itself usually already exists.
     + The EFS CSI driver doesn’t create new file systems; instead:
       + It creates **access points** inside an existing EFS file system.
       + hese access points act as isolated directories for each PV 


  
 **EBS or EFS static:**
  1. Install drivers
  2. Give permissions in EC2 role
  3. create volume
  4. create PV(physical representation of volume)
  5. create PVC
  6. volume mount to pod
  if EBS volume should be in the same az as in instance
  if EFS SG should allow port 2049

**EBS or EFS dynamic:**
  1. Install drivers
  2. Give permissions in EC2 role
  3. create storage class
  4. create PVC with SC name, volume and PV will be created automatically
  5. volume mount to pod
  in case of dynamic pod pvc creates volume, so it creates in the same az where ec2 instance is there
  if EFS SG should allow port 2049

## Ephemeral Volumes:
 + Means these volumes are temporary, It's lifecycle is short.
 + **Lifecycle depends on pod. When the pod terminates/restarts the data is gone.**
 + We shouldn't use them for statlful set applications.
 + The data is stored at `/var/lib/kubelet/pods/<pod-UID>/volumes/kubernetes.io~empty-dir/<volume-name>/` in node(host)
 + That <pod-UID> changes when a Pod is deleted and recreated (even if it has the same name).
 + When the old pod object is gone, Kubernetes deletes that directory, so the data is lost.
 + if the container restarts inside the same pod, the pod UID stays the same and data persists.
 + But When the pod terminates for any reason—a restart, a failure, or a manual deletion—the ephemeral volume is also deleted. UID changes so no data. 
 + `Ephemeral volume lifetime = lifetime of the pod UID`
 + There are emptyDir, hostPath.
----
 + EKS admins control cluster level objects...
 + as a roboshop devops engineer, you need a disk to be created for your application,
 + we will raise a ticket for this. GB, filesystem type(ext4), etc..it is approved by roboshop team lead/delivery lead. Storage team also checks this and it is approved their team leader..
 + then storage team creates the disk...
 + provide these disk details to EKS admin, then they create PV for us and tell us the name.
 + PV --> K8 resource, physical representation of the actual storage
 + PVC --> it is the claim done by pods to mount the storage
 + SC --> k8 object used to create the volume dynamically...
 


    

   
 
       
      

 
