
## Boot strapping our environment.

From within `<Project root>/devlab1/`


## Deployment

Well, lets first put this out there, this is not the easiest to try and keep clean, we have quite a few different patterns that I want to demostrate here.

**Catalogs:**

1. Remote Catalogs inside JDBC based datastore, PostgreSQL in this case.

**Lakehouse Storage**

1. Remote Lakehouse storage inside MinIO/S3 object store.

- everything in `<Project root>/devlab1` is for Lakehouse -> storage on MinIO/S3 
  
  
## Running a stack

We start with building the containers, for this we have one set, will try and add enough comments into the Apache Flink and Apache Fluss (Incubating) `Dockerfiles` to make it as clear as possible what JAR's are included for what purpose/scenario.

After building the containers we will come to either devlab0 or devlab1 and then do the various 

- `make run`
  
- `make deploy`

- `make ahs `

- `make txns`

- Execute the load generator via the `<project root>/shadowtraffic/run_pg#.sh` script

- `make tier`
