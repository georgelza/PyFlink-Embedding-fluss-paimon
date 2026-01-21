## An Pratical Example "How to" Source data from a Postgres, Push it into Apache Fluss with Paimon based Lakehouse tier'd onto S3.

### Blog Overview

Let's write a fully workable demo with all the required docker-compose code, Dockerfiles listing all required Jar's and Flink SQL showing how to create data, CDC consume it from PostgreSQL, push via Apache Flink into Apache Fluss (Incubating) and Lakehouse tier it down into Apache Paimon hosted on FileSystem and S3 based Object, while utilising an JDBC based metastore/catalog, itself persisted into PostgreSQL.


### Our data flow:

1. Use [ShadowTraffic](https://shadowtraffic.io) to create 2 data products which we insert into PostgreSQL, (2 Tables, accountHolder and transactions).
   
2. Use Apahce Flink CDC to consume our inbound data into PostgreSQL exposing it in Apache Flink as Tables.

3. Select from our Apache Flink tables, inserting into Apache Fluss Tables.

4. Enable Lakehouse tiering... 

Here we have 2 examples, 

   1. devlab0

      1. Configure Apache Fluss tiering into Apache Paimon based table as our Lakehouse tier, configured onto File system with a File system based catalog

      2. Configure Apache Fluss tiering into Apache Paimon based table as our Lakehouse tier, configured onto File system with JDBC based catalog

   2. devlab1

      1. Configure Apache Fluss tiering into Apache Paimon based table as our Lakehouse tier, configured onto MinIO/S3 Object stoore with an JDBC based catalog.



All Filesystem based options (Example 1 & 2) can be found in the `devlab0` subdirectory structure.

**NOTES:** For using local File System during testing as lakehouse storage, Dual mount your ./tmp/paimon in container to say ./data/paimon: locally, This needs to be done in BOTH the Flink containers (Jobmanager, TaskManager) and the Fluss Incubating containers (coordinator-server and tablet-servers).


All MinIO/S3 (3) based options (Example 3) can befound in the `devlab1` subdirectory structure.


So the previous Blog included calculating embeddings (using an PyFlink based UDF, See: `<Project root/devlab#/pyflink/udfs/`) and pushing that directly into our Apache Paimon datastore.

At this time Apache Fluss does not support Array of Float or Array of Double as column type so for this blog we're excluding that as part of our Select / insert stagement. This will however be very easy to add once it is supported in an up coming Apache Fluss release.


Well mission accomplished.

Re our 2 Data products, 

We create accountHolder records (that defines a person, family at an address) and then financial transactions (well who can life without spending money) modeled as a outbound and inbound event, very real world.

These are all inserted into a PostgreSQL database/tables.

We then utilize as per above Apache Flink CDC to consume these into trancient tables inside Apache Flink (we're using Generic in memory based catalog).

From here we use the below `Insert into <Table> (<columns>) select <columns> from Y;` statement to push our data into our Apache Fluss (Incubating) table.

```sql
Insert into fluss_catalog.finflow.<target table>
select (
        fields
    , ...
    , ...
    ,generate_<function>_embedding(
            fields
        , ...
        , ...
    ) AS embedding_vector
    ,384                    AS embedding_dimensions
    ,CURRENT_TIMESTAMP      AS embedding_timestamp
    ,created_at
) 
from c_cdcsource.demog.<source table>;~
```

While all of this sounds simply, it was/is a find dance to make sure all the required JAR files are include in our Apache Flink and Apache Fluss (incubating) containers, and all the relevant properties are set for our various services in our Docker-compose configuration. The last bit being the required values for our Apache Flink tiering job.


The Blog would not have "eventually" worked without the information in the work done in [Hands on Fluss Lakehouse](https://fluss.apache.org/blog/hands-on-fluss-lakehouse/) post.


### NOTES: 

Below is our Apache Fluss (Incubating) Dockerfile - JAR's

```bash
# Dockerfile
# 1. Paimon / JDBC catalog
RUN mkdir -p /opt/fluss/plugins/paimon
COPY stage/postgresql-42.7.6.jar            ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-bundle-1.3.1.jar          ${FLUSS_HOME}/plugins/paimon

# 2. Needed for S3 storage tier
COPY stage/paimon-s3-1.3.1.jar              ${FLUSS_HOME}/plugins/paimon

# 3. Needed for S3 storage tier
RUN mv ${FLUSS_HOME}/plugins/s3/fluss-fs-s3-0.8.0-incubating.jar  ${FLUSS_HOME}/lib
RUN rm -rf ${FLUSS_HOME}/plugins/s3

# 3. Lets make sure with our copying of JARs that all is owned by the right user/group.
RUN chown -R fluss:fluss ${FLUSS_HOME}
```

The next one is our Apache Flink Dockerfile - JAR's

```bash

```

Once we have these 2 containers build we can run the 2 labs, as contained in devlab0 and devlab1.
The biggest difference now being the coordinator and tablet-server configurations as per the docker-compose-*.yaml files in devlab0 and devlab1.

Lastly is the configuration of our Apache Flink tiering job. see devlab#/Makefile for these, at the end of the file... ;)

Below is a consolidaation of the information we have in our various Apache Fluss docker-compose service definitions, as required by the tier job to move our data from the Apache Fluss table into our Lakehouse based tier based on Apache Paimon with storage on S3 with for our JDBC based catalog.

```yaml
# Makefile
tier:
	@echo "-- Submitting Paimon Tiering Job->JDBC Catalog..."
	docker compose exec --interactive --tty jobmanager \
		/opt/flink/bin/flink run \
			-Dpipeline.name="My Fluss Tiering Service, output to Paimon" \
			-Dparallelism.default=2 \
			/opt/flink/lib/fluss-flink-tiering-0.8.0-incubating.jar \
			--fluss.bootstrap.servers coordinator-server:9123 \
			--datalake.format paimon \                                  # What format do we want the Lakehouse table to be in
			--datalake.paimon.type paimon \
			--datalake.paimon.metastore jdbc \                          # What catalog are we going to be using
			--datalake.paimon.catalog-key jdbc \
			--datalake.paimon.uri jdbc:postgresql://postgrescat:5432/catalogs?currentSchema=paimon_jdbc \       # PostgreSQL Catalog URI
			--datalake.paimon.jdbc.user dbadmin \                                                               # PostgreSQL username
			--datalake.paimon.jdbc.password dbpassword \                                                        # PostgreSQL password
			--datalake.paimon.jdbc.driver org.postgresql.Driver \
          	--datalake.paimon.warehouse s3://warehouse/paimon \                                                 # MinIO/S3 warehouse location
			--datalake.paimon.s3.endpoint http://minio:9000 \                                                   # MinIO/S3 server endpoint
			--datalake.paimon.s3.access-key mnadmin \                                                           # MinIO credentials
			--datalake.paimon.s3.secret-key mnpassword \
			--datalake.paimon.s3.path.style.access true                                                         # Usee MinIO path structure
```


**Previous Blog** As background context.

BLOG: [Using Pyflink UDF to calculate embedding vectors on inbound tables via Flink CDC](https://medium.com/@georgelza/using-pyflink-udf-to-calculate-embedding-vectors-on-inbound-tables-via-flink-f77ce605a429)

GIT REPO: [PyFlink_Embedder](https://github.com/georgelza/PyFlink_Embedder.git)



## Deployment


**NOTE:** For the above deploy I ran into an interesting situation. As you will notice the `PostgreSQL` source table is created in the `c_cdcsource` catalog. Now that catalog is of type `generic in memory` as per **Apache Flink**. So whats so special about that, well, it’s session scoped, **ONLY**. This means whatever you create in the catalog is only available/visible for that session, during that session. 

Ok. Now this means when we create the catalog, the source `PostgreSQL` reference, the UDF referencing the source table, well, they all have to be done in one session. So… how did we get around this, why is this a issue. Well we still want to compartmentalise our code, as in keep the catalog create in the catalog script, the CDC source table creates in their script and then the UDF separate as well as its registration. 

Code duplication is also note a great idea, we want to re-use these bits.

So at this point, I’m going to say, look at our `Makefile`, at the deploy: and deploy-fs: sections, and how they call `master:`, and how we use the “>” operator to build a `master.sql` script, which we then execute in `deploy:` Makefile command. 

There is still room for improvement here, but for now this worked.


- Generate data,

  - Execute our `Shadowtraffic` based data generator to create our data products for:
    
    #1 AccountHolders, 
    
    #2 Financial Transactions tables.
    
    This will Ooutput into two PostgreSQL Tables provided by our `postgrescdc` docker-compose service.
    The data generation is run by executing `<Project Root>/shadowtraffic/run_pg1.sh`.
    If you want to increase the data generate rate execute `<Project Root>/shadowtraffic/run_pg2.sh`.


## Regarding our Stack

The following stack is deployed using one of the provided  `<Project Root>/devlab/docker-compose-*.yaml` files as per above.

- [Apache Flink 1.20.2](https://nightlies.apache.org/flink/flink-docs-release-1.20/)                   

- [Apache Flink CDC 3.5.0](https://nightlies.apache.org/flink/flink-cdc-docs-release-3.5/)

- [Apache Paimon 1.3.1.](https://paimon.apache.org)

- [PostgreSQL 15](https://www.postgresql.org)

- [MinIO](https://www.min.io) - Project has gone into Maintenance mode... 

- [ShadowTraffic](https://shadowtraffic.io)




**THE END**


Thanks for following. Till next time.


### The Rabbit Hole

<img src="blog-doc/diagrams/rabbithole.jpg" alt="Our Build" width="600">

And like that we’re done with our little trip down another Rabbit Hole.

## CREDITS

This blog would not have been possible without the assistance of [Yuxia Luo](https://www.linkedin.com/in/yuxia-luo-32720336a/) from the Fluss community/Project. He countless times assisted when I got stuck with these nasty JAR' Jar Jar conflicts/configuration, not sure what we want to call it...


## ABOUT ME

I’m a techie, a technologist, always curious, love data, have for as long as I can remember always worked with data in one form or the other, Database admin, Database product lead, data platforms architect, infrastructure architect hosting databases, backing it up, optimizing performance, accessing it. Data data data… it makes the world go round.
In recent years, pivoted into a more generic Technology Architect role, capable of full stack architecture.

### By: George Leonard

- georgelza@gmail.com
- https://www.linkedin.com/in/george-leonard-945b502/
- https://medium.com/@georgelza



<img src="blog-doc/diagrams/TechCentralFeb2020-george-leonard.jpg" alt="Our Build" width="600">




