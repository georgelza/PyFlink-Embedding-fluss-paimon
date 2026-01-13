
## Boot strapping our environment.

From within `<Project root>/devlab/`

We can take the environment through various phases. 


- Our `devlab/creFlinkFlows/1.1.creCat.sql` script also provides the required command to create Paimon based catalog.
  
- If you want, you can deploy the Apache Flink Cluster, allowing you move data across the Flink stack and additionally the accompanying PyFlink routines that will calculate vector embedding values for the accountholders and transactions. These values will be pushed as a new record into accountholder and transactions tables (which will be stored in Apache Paimon).

## Deployment

Well, lets first put this out there, this is not the easiest to try and keep clean, we have quite a few different patterns that I want to demostrate here.

**Catalogs:**

1. Local/FS Catalog

- Local/FS -> Paimon

1. Remote Catalogs

- JDBC -> Paimon and Iceberg
  
- REST/Polaris -> Iceberg

**Lakehouse Storage**

1. Local/FS storage

2. Remote MinIO/S3 storage

Base on the above... please bear with me while I try and keep the project repo making sense.

Idea... 

- everything in devlab0 is for Lakehouse -> storage on local file system
  
- everything in devlab1 is for Lakehouse -> storage on MinIO/S3 
  
  
## Running a stack

Both devlab0 and devlab1 will follow the same pattern.

We start with building the containers, for this we have one set, will try and add enough comments into the Apache Flink and Apache Fluss (Incubating) Dockerfiles to make it as clear as possible what JAR's are included for what purpose/scenario.

After building the containers we will come to either devlab0 or devlab1 and then do the various 

- make run-<option>

- make deploy, 

- make ahs_fluss, 

- Execute the load generator via the ShadoTraffic/run_pg#.sh script

- make tier_<>.