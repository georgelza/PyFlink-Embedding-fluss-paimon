
.DEFAULT_GOAL := help
include .env

define HELP

Available commands:

- build: 		Build required Docker images (Flink with CDC)

- run:   		Start All services (Flink, Fluss, PostgreSQL & Minio/S3)
- deploy:		Deploy all structures required for our MinIO/S3 based storage/JDBC Catalog

- run-fs:  		Start All services (Flink, Fluss, PostgreSQL), output onto Filesystem, Catalog on Filesystem
- run-j:  		Start All services (Flink, Fluss, PostgreSQL), output onto Filesystem, Catalog in JDBC
- deploy-fs:	Deploy all structures required for our Filesystem based storage/JDBC Catalog

- ahs_paimon	Deploy insert statement for accountHolder data feed into Paimon datastore
- txns_paimon	Deploy insert statement for transaction data feed into Paimon datastore

- ahs_fluss		Deploy insert statement for accountHolder data feed into Fluss datastore
- txns_fluss	Deploy insert statement for transaction data feed into Fluss datastore
- tier			Kick off Fluss Tiering Job

- stop:  		Stop the project
- start: 		Restart a stopped project
- down:  		Tear down the project, clean directories

- ps:    		how all running containers
- logs:  		Show/tail logs
- logsf: 		Stream logs
- watch: 		Watch logs
- fsql			Open Flink-Sql console
- jm			Open Flink Jobmanager console
- cs			Open Fluss Coordinator-server console


endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help


#	docker rmi $(docker images -q --filter "dangling=true")

build:
#	@cd ../infrastructure && make pull && make build
	@cd ../infrastructure && make build
.PHONY: build

# a Default...
run: run-fs

# S3/Minio based  => Default
#
# Default as it contains more services, and the larger set of services are all
# stopped/deteled when you do make down or docker-compose down, the default
# docker-compose.yml file is read and those services are torn down.
run-s3:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc 
	mkdir -p ./data/fluss
	mkdir -p ./data/zk/data ./data/zk/datalogs
	mkdir -p ./data/minio

	@echo "🚀 Starting Flink & Fluss stack, supporting services (PostgreSQL & MinIO)..."
	docker compose -f docker-compose.yml -p flussvector up -d \
		jobmanager taskmanager \
 		postgrescdc \
		zookeeper coordinator-server tablet-server-1 tablet-server-2 tablet-server-3 \
		minio minio-client \
		--remove-orphans
	@echo "✅ Flink & Fluss stack with supporting services started successfully"
.PHONY: run-s3


# File System based
run-fs:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc 
	mkdir -p ./data/fluss
	mkdir -p ./data/zk/data ./data/zk/datalogs

	@echo "🚀 Starting Flink & Fluss stack, supporting services (PostgreSQL)..."
	docker compose -f docker-compose-fs.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc \
		zookeeper coordinator-server tablet-server-1 tablet-server-2 tablet-server-3 \
		--remove-orphans
	@echo "✅ Flink & Fluss stack with supporting services started successfully"
.PHONY: run-f

run-j:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc 
	mkdir -p ./data/fluss
	mkdir -p ./data/zk/data ./data/zk/datalogs

	@echo "🚀 Starting Flink & Fluss stack, supporting services (PostgreSQL)..."
	docker compose -f docker-compose-jdbc.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc \
		zookeeper coordinator-server tablet-server-1 tablet-server-2 tablet-server-3 \
		--remove-orphans
	@echo "✅ Flink & Fluss stack with supporting services started successfully"
.PHONY: run-j

stop:
	docker compose stop

start:
	docker compose start

down:	
	docker compose down
	cd data/; rm -rf flink
	cd data/; rm -rf postgrescdc
	cd data/; rm -rf minio
	cd data/; rm -rf fluss
	cd data/; rm -rf zk

ps:
	docker compose ps

logs:
	docker compose logs

logsf:
	docker compose logs -f

watch:
	watch docker compose ps

fsql:
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh

jm:
	docker compose exec --interactive --tty jobmanager /bin/bash

cs:
	docker compose exec --interactive --tty coordinator-server /bin/bash

# S3/Minio based  => Default
master:
	@echo "-- Generated S3 based master.sql" > ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.0.creCatGen.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.1.creCatPaimon-s3.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.2.creCatFluss.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/3.1.creTargetFinflow-Paimon.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/3.1.creTargetFinflow-Fluss.sql >> ./creFlinkFlows/master.sql
	@echo "✅ master.sql for MinIO/S3 Storage generated"

# File System based
master-fs:
	@echo "-- Generated FS based master.sql" > ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.0.creCatGen.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.1.creCatPaimon-fs.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.2.creCatFluss.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/3.1.creTargetFinflow-Paimon.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/3.1.creTargetFinflow-Fluss.sql >> ./creFlinkFlows/master.sql
	@echo "✅ master.sql for FS Storage generated"


deploy: master
	@echo "-- Deploying Fluss & Paimon based Catalog with MinIO/S3 Storage..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/master.sql

deploy-fs: master-fs
	@echo "-- Deploying Fluss & Paimon based Catalog with Filesystem..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/master.sql


# Single worker/single thread, outputting from flink directly to Paimon
ahs_paimon:
	@echo "-- Submitting Account Holders Embedding Job, output to Paimon..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.1.creInsertsAhSingle_paimon.sql

txns_paimon:
	@echo "-- Submitting Transaction Embedding Job, output to Paimon..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.2.creInsertsTxnSingle_paimon.sql


# Single worker/sing thread, outputting from Flink to Fluss and down into Lakehouse tier
ahs_fluss:
	@echo "-- Submitting Account Holders Embedding Job, output to Fluss..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.1.creInsertsAhSingle_fluss.sql

txns_fluss:
	@echo "-- Submitting Transaction Embedding Job, output to Fluss..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.2.creInsertsTxnSingle_fluss.sql


# Multiple workers/multiple threads
# Need to figure this out still.


# https://fluss.apache.org/docs/maintenance/tiered-storage/lakehouse-storage/#enable-lakehouse-storage	
tier_p:
	@echo "-- Submitting Paimon Tiering Job..."
	docker compose exec --interactive --tty jobmanager \
		/opt/flink/bin/flink run \
			-Dpipeline.name="My Fluss Tiering Service, output to Paimon" \
			-Dparallelism.default=2 \
			/opt/flink/lib/fluss-flink-tiering-0.8.0-incubating.jar \
			--fluss.bootstrap.servers coordinator-server:9123 \
			--datalake.format paimon \
			--datalake.paimon.warehouse /paimon \
			--datalake.paimon.metastore filesystem 

tier_i:
	@echo "-- Submitting Iceberg Tiering Job..."
	docker compose exec --interactive --tty jobmanager \
		/opt/flink/bin/flink run \
			-Dpipeline.name="My Fluss Tiering Service, output to Iceberg" \
			-Dparallelism.default=2 \
			/opt/flink/lib/fluss-flink-tiering-0.8.0-incubating.jar \
			--fluss.bootstrap.servers coordinator-server:9123 \
			--datalake.format iceberg \
			--datalake.iceberg.type hadoop \
			--datalake.iceberg.warehouse /paimon