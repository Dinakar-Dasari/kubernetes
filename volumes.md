**_Why Volumes?_**
+ Kubernetes pods are ephemeral. When a pod processes data and is eventually deleted, any data stored within it is lost unless a volume is attached. Volumes in Kubernetes ensure that essential data remains available even after a pod’s lifecycle ends.
+ For single node:
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
          | **ReadWriteOnce (RWO)** | One node can read/write(Like USB, at a time can be connected to only one device)                               |
          | **ReadOnlyMany (ROX)**  | Many nodes can only read                              |
          | **ReadWriteMany (RWX)** | Many nodes can read/write (good for shared workloads) |
      + **_Capacity:_** Specifies the allocated storage size (1Gi in this example).
      + **_Volume Type:_** Here, we use a host path to utilize local node storage.
        +  HostPath is useful for demonstration purposes,it is not recommended for production environments
       
  + **_Persistent Volume Claims(PVC):_**
    + Kubernetes administrators are responsible for creating PVs, while users create PVCs to request and utilize that storage.
    + It's like storage is available in PV, but to use we need to request through PVC.
      + _"Hey Kubernetes, I need 5Gi of storage with read-write access."_
    + Once a PVC is defined, Kubernetes automatically binds it to an available PV that meets specific criteria such as capacity, access modes, volume modes, storage class, and additional parameters.
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
  +   Create a PVC for 10Gi of storage.
  +   It uses a StorageClass backed by AWS EBS (or) if created manually then it refers that PV.
  +   Kubernetes creates a new EBS disk.
  +   Pod uses the PVC → writes data to the EBS disk.
  +   Pod dies? Data still there. Pod moves? Data is reattached.
 
+  PV --> cluster level
+  PVC --> Name Space level
+  EKS admins control cluster level objects(PV).
+  As a roboshop devops engineer, you need a disk to be created for your application,
+  we will raise a ticket for this. 5 GB, filesystem type(ext4), etc..it is approved by roboshop team lead/delivery lead. Storage team also checks this and it is approved their team leader.
+  then storage team creates the disk.
+  provide these disk details to EKS admin, then they create PV for us and tell us the name.
+  EBS size is fixed, EFS is elastic it automatically grows upto 48TB.
+  EBS will not have any SG attached, but EFS is in network, so there will be SG attached and 2049 should be allowed.
+  Refer `session-62` notes for EBS/EFS volume setup
  
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

   
 
       
      

 
