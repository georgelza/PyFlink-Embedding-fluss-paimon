## Using Pyflink UDF to calculate embedding vectors on inbound tables via Flink CDC


Blog Overview / PLAN

Write workable demo's with the required docker-compose and Dockerfiles and all required builds and Flink SQL showing

1. ShadowTraffic -> PostgreSQL  (2 Tables, accountHolder and transactions), at this stage we excluding the Array[Float column] as computed by the included PyFlink embedding UDF.

2. PostgreSQL -> CDC -> Flink

3. Flink ->Fluss

4. Enable Lakehouse
   1. Fluss -> Paimon on FS with FS catalog
   2. Fluss -> Paimon on FS with JDBC catalog
   3. Fluss -> Paimon on MinIO/S3 with FS catalog
   4. Fluss -> Paimon on MinIO/S3 with JDBC catalog

All Filesystem (1 & 2) based options will be located in the `devlab0` subdirectory structure.

All MinIO/S3 (3 & 4) based options will be located in the `devlab1` subdirectory structure.



So, the original idea, generate data, do embedding using Pyflink, store into a lakehouse, simple.

Well mission accomplished, even if we did changed some of the original outputs, will see if i can circle back on the next demo/blog... ye, there is another one already drawn out, started.

Our little project, create accountHolder records (that defines a person, family at an address) and then financial transactions (well who can life without spending money) modeled as a outbound and inbound event, very real world.

These are all inserted into a PostgreSQL database/tables.

We then utilize Apache Flink CDC to consume these into trancient tables inside Apache Flink (we're using Generic in memory catalog).

Next up, we need to do the embedding calculation, this is done using two Pyflink User Defined functions (UDF), (See: `<Project root/devlab#/pyflink/udfs/`).

These are called as per below, as inline function calls, returning the embedding vector that is inserted into our lakehouse, based on Apache Paimon.

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

**FOR NOW THE ABOVE:
**    
    GENERATE_<>_EMBEDDING(
        fields
        ...
    )
is not part of the Select statment and insert statement as Apache Fluss () cannot accept array[Float] or array[double]


**Previous blog** As background context.

BLOG: [Using Pyflink UDF to calculate embedding vectors on inbound tables via Flink CDC](https://medium.com/@georgelza/using-pyflink-udf-to-calculate-embedding-vectors-on-inbound-tables-via-flink-f77ce605a429)

GIT REPO: [PyFlink_Embedder](https://github.com/georgelza/PyFlink_Embedder.git)


## Overview

The stack allows for the Lakehouse tables to either be created on S3 Object storage hosted on MinIO container or on the local file system `<Project root/devlab/data/flink/paimon/`.



## Deployment



**NOTE:** For the above deploy I ran into an interesting situation. As you will notice the `PostgreSQL` source table is created in the `c_cdcsource` catalog. Now that catalog is of type `generic in memory` as per **Apache Flink**. So whats so special about that, well, it’s session scoped, **ONLY**. This means whatever you create in the catalog is only available/visible for that session, during that session. 

Ok. Now this means when we create the catalog, the source `PostgreSQL` reference, the UDF referencing the source table, well, they all have to be done in one session. So… how did we get around this, why is this a issue. Well we still want to compartmentalise our code, as in keep the catalog create in the catalog script, the CDC source table creates in their script and then the UDF separate as well as its registration. 

Code duplication is also note a great idea, we want to re-use these bits.

So at this point, I’m going to say, look at our `Makefile`, at the deploy: and deploy-fs: sections, and how they call `master:` or `master-fs:`, and how we use the “>” operator to build a `master.sql` or `master-fs.sql` script, which we then execute in `deploy:` or `deploy-fs:`. 

There is still room for improvement here, but for now this worked.





- Generate data,

  - Execute our `Shadowtraffic` based data generator to create our data products for #1 AccountHolders, #2 Financial Transactions tables.
    This will Ooutput into two PostgreSQL Tables provided by our `postgrescdc` docker-compose service.
    The data generation is run by executing `<Project Root>/shadowtraffic/run_pg1.sh`.
    If you want to increase the data generate rate execute `<Project Root>/shadowtraffic/run_pg2.sh`.




## Regarding our Stack

The following stack is deployed using one of the provided  `<Project Root>/devlab/docker-compose-*.yaml` files as per above.

- [Apache Flink 1.20.2](https://nightlies.apache.org/flink/flink-docs-release-1.20/)                   

- [Apache Flink CDC 3.5.0](https://nightlies.apache.org/flink/flink-cdc-docs-release-3.5/)

- [Apache Paimon 1.3.1.](https://paimon.apache.org)

- [PostgreSQL 12](https://www.postgresql.org)

- [MinIO](https://www.min.io) - Project has gone into Maintenance mode... 

- [ShadowTraffic](https://shadowtraffic.io)




**THE END**


Thanks for following. Till next time.


### The Rabbit Hole

<img src="blog-doc/diagrams/rabbithole.jpg" alt="Our Build" width="600">

And like that we’re done with our little trip down another Rabbit Hole.

## ABOUT ME

I’m a techie, a technologist, always curious, love data, have for as long as I can remember always worked with data in one form or the other, Database admin, Database product lead, data platforms architect, infrastructure architect hosting databases, backing it up, optimizing performance, accessing it. Data data data… it makes the world go round.
In recent years, pivoted into a more generic Technology Architect role, capable of full stack architecture.

### By: George Leonard

- georgelza@gmail.com
- https://www.linkedin.com/in/george-leonard-945b502/
- https://medium.com/@georgelza



<img src="blog-doc/diagrams/TechCentralFeb2020-george-leonard.jpg" alt="Our Build" width="600">




