
## Boot strapping our environment.

From within `<Project root>/devlab1/`


## Deployment

Well, lets first put this out there, this is not the easiest to try and keep clean, we have quite a few different patterns that I want to demostrate here.

**Catalogs:**

1. Local Catalog on file system.

2. Remote Catalogs inside JDBC based datastore, PostgreSQL in this case.

**Lakehouse Storage**

1. Local Lakehouse storage on file system.

2. Remote Lakehouse storage inside MinIO/S3 object store.

Base on the above... please bear with me while I try and keep the project repo making sense.

Idea... 

- everything in `<Project root>/devlab0` is for Lakehouse -> storage on local file system

  - **NOTES:** For using local File System during testing as lakehouse storage, Dual mount your ./tmp/paimon in container to say ./data/paimon: locally, This needs to be done in BOTH the Flink containers (Jobmanager, TaskManager) and the Fluss Incubating containers (coordinator-server and tablet-servers).

  
## Running a stack


We start with building the containers, for this we have one set, will try and add enough comments into the Apache Flink and Apache Fluss (Incubating) `Dockerfiles` to make it as clear as possible what JAR's are included for what purpose/scenario.

After building the containers we will come to either devlab0 or devlab1 and then do the various 

- `make run-<option>`

  - `make run`
  
  - `make run-fs`

  - `make run-jdbc`

- `make deploy`

- `make ahs `

- `make txns`

- Execute the load generator via the `<project root>/shadowtraffic/run_pg#.sh` script

- `make tier_<option>`

  - if `make run` as per above is `run` then make `make tier_fs`

  - if `make run-<option>` as per above is `run-fs`, then make `make tier_fs`

  - if `make run-<option>` as per above is `run-jdbc`, then make `make tier_jdbc`