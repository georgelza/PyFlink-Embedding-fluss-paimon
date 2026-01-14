
.DEFAULT_GOAL := help
include .env

define HELP

Available commands:

- build: 		Build required Docker images (Flink with CDC)

- run:   		Start All services -> Paimon, FS Catalog
- run-pm-jdbc:  Start All services -> Paimon, JDBC Catalog
- run-ib-jdbc:  Start All services -> Iceberg, JDBC Catalog
- run-ib-pol:   Start All services -> Iceberg, Polaris/REST Catalog

- deploy:		Deploy all structures

- ahs 			Deploy insert statement for accountHolder data feed into Fluss datastore
- txns			Deploy insert statement for transaction data feed into Fluss datastore

- tier_pm_fs	Kick off Fluss Tiering Job - Paimon on FS Catalog
- tier_pm_jdbc	Kick off Fluss Tiering Job - Paimon on JDBC Catalog
- tier_ib_jdbc	Kick off Fluss Tiering Job - Iceberg on JDBC Catalog
- tier_ib_pol	Kick off Fluss Tiering Job - Iceberg on Polaris/REST Catalog

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


# Default - File System based Catalog, Paimon, ...
run:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc ./data/postgrescat
	mkdir -p ./data/fluss
	mkdir -p ./data/zk/data ./data/zk/datalogs

	@echo "🚀 Starting Flink & Fluss stack, supporting services (PostgreSQL)... for Paimon Filesystem Catalog"
	docker compose -f docker-compose-pm-fs.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc \
		zookeeper coordinator-server tablet-server-1 tablet-server-2 tablet-server-3 \
		--remove-orphans
	@echo "✅ Flink & Fluss stack with supporting services started successfully"
.PHONY: run


# JDBC Based Catalog, Paimon
run-pm-jdbc:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc ./data/postgrescat	
	mkdir -p ./data/fluss
	mkdir -p ./data/zk/data ./data/zk/datalogs

	@echo "🚀 Starting Flink & Fluss stack, supporting services (PostgreSQL)... for Paimon JDBC Catalog"
	docker compose -f docker-compose-pm-jdbc.yml -p flussvector up -d \
		jobmanager taskmanager \
 	    postgrescdc postgrescat \
		zookeeper coordinator-server tablet-server-1 tablet-server-2 tablet-server-3 \
		--remove-orphans
	@echo "✅ Flink & Fluss stack with supporting services started successfully"
.PHONY: run-pm-jdbc

# JDBC Based Catalog, Iceberg
run-ib-jdbc:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc ./data/postgrescat
	mkdir -p ./data/fluss
	mkdir -p ./data/zk/data ./data/zk/datalogs

	@echo "🚀 Starting Flink & Fluss stack, supporting services (PostgreSQL)... for Iceberg JDBC Catalog"
	docker compose -f docker-compose-ib-jdbc.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc postgrescat \
		zookeeper coordinator-server tablet-server-1 tablet-server-2 tablet-server-3 \
		--remove-orphans
	@echo "✅ Flink & Fluss stack with supporting services started successfully"
.PHONY: run-ib-j


# Polaris Based Catalog, Iceberg
run-ib-pol:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc ./data/postgrescat
	mkdir -p ./data/fluss
	mkdir -p ./data/zk/data ./data/zk/datalogs

	@echo "🚀 Starting Flink & Fluss stack, supporting services (PostgreSQL)... for Iceberg Polaris/REST Catalog"
	docker compose -f docker-compose-ib-polaris.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc postgrescat \
		zookeeper coordinator-server tablet-server-1 tablet-server-2 tablet-server-3 \
		--remove-orphans
	@echo "✅ Flink & Fluss stack with supporting services started successfully"
.PHONY: run-ib-pol


stop:
	docker compose stop

start:
	docker compose start

down:	
	docker compose down
	cd data/; rm -rf flink
	cd data/; rm -rf postgrescdc
	cd data/; rm -rf postgrescat
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

# File System based
master:
	@echo "-- Generated FS based master.sql" > ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.0.creCatGen.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.2.creCatFluss.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/3.1.creTargetFinflow-Fluss.sql >> ./creFlinkFlows/master.sql
	@echo "✅ master.sql for FS Storage generated"


deploy: master
	@echo "-- Deploying Fluss & Paimon based Catalog with Filesystem..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/master.sql


# Single worker/sing thread, outputting from Flink to Fluss and down into Lakehouse tier
ahs:
	@echo "-- Submitting Account Holders Embedding Job, output to Fluss..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.1.creInsertsAhSingle_fluss.sql

txns:
	@echo "-- Submitting Transaction Embedding Job, output to Fluss..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.2.creInsertsTxnSingle_fluss.sql


# Multiple workers/multiple threads
# Need to figure this out still.


# https://fluss.apache.org/docs/maintenance/tiered-storage/lakehouse-storage/#enable-lakehouse-storage	
tier_pm_fs:
	@echo "-- Submitting Paimon Tiering Job->FS Catalog..."
	docker compose exec --interactive --tty jobmanager \
		/opt/flink/bin/flink run \
			-Dpipeline.name="My Fluss Tiering Service, output to Paimon" \
			-Dparallelism.default=2 \
			/opt/flink/lib/fluss-flink-tiering-0.8.0-incubating.jar \
			--fluss.bootstrap.servers coordinator-server:9123 \
			--datalake.format paimon \
			--datalake.paimon.warehouse /tmp/paimon \
			--datalake.paimon.metastore filesystem 

tier_pm_jdbc:
	@echo "-- Submitting Paimon Tiering Job->JDBC Catalog..."
	docker compose exec --interactive --tty jobmanager \
		/opt/flink/bin/flink run \
			-Dpipeline.name="My Fluss Tiering Service, output to Paimon" \
			-Dparallelism.default=2 \
			/opt/flink/lib/fluss-flink-tiering-0.8.0-incubating.jar \
			--fluss.bootstrap.servers coordinator-server:9123 \
			--datalake.format paimon \
			--datalake.paimon.warehouse /tmp/paimon \
			--datalake.paimon.metastore jdbc 

tier_ib_jdbc:
	@echo "-- Submitting Iceberg Tiering Job->JDBC Catalog..."
	docker compose exec --interactive --tty jobmanager \
		/opt/flink/bin/flink run \
			-Dpipeline.name="My Fluss Tiering Service, output to Iceberg" \
			-Dparallelism.default=2 \
			/opt/flink/lib/fluss-flink-tiering-0.8.0-incubating.jar \
			--fluss.bootstrap.servers coordinator-server:9123 \
			--datalake.format iceberg \
			--datalake.iceberg.warehouse /tmp/iceberg \
			--datalake.iceberg.metastore jdbc

tier_ib_pol:
	@echo "-- Submitting Iceberg Tiering Job->REST Catalog..."
	docker compose exec --interactive --tty jobmanager \
		/opt/flink/bin/flink run \
			-Dpipeline.name="My Fluss Tiering Service, output to Iceberg" \
			-Dparallelism.default=2 \
			/opt/flink/lib/fluss-flink-tiering-0.8.0-incubating.jar \
			--fluss.bootstrap.servers coordinator-server:9123 \
			--datalake.format iceberg \
			--datalake.iceberg.warehouse /tmp/iceberg \
			--datalake.iceberg.metastore REST