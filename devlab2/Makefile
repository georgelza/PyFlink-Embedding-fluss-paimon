
.DEFAULT_GOAL := help
include .env

define HELP

Available commands:

- build: 		Build required Docker images (Flink with CDC)

- run:   		Start All services -> Paimon, FS Catalog
- run-pm-jdbc:  Start All services -> Paimon, JDBC Catalog
- run-ib-jdbc:  Start All services -> Iceberg, JDBC Catalog
- run-ib-pol:   Start All services -> Iceberg, Polaris Catalog

- deploy:		Deploy all structures

- ahs_paimon	Deploy insert statement for accountHolder data feed directly into Paimon datastore
- txns_paimon	Deploy insert statement for transaction data feed directly into Paimon datastore


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
	mkdir -p ./data/postgrescdc 

	@echo "🚀 Starting Flink stack, supporting services (PostgreSQL)... for Paimon Filesystem Catalog"
	docker compose -f docker-compose-pm-fs.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc \
		--remove-orphans
	@echo "✅ Flink stack with supporting services started successfully"
.PHONY: run


# JDBC Based Catalog, Paimon
run-pm-jdbc:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc 

	@echo "🚀 Starting Flink stack, supporting services (PostgreSQL)... for Paimon JDBC Catalog"
	docker compose -f docker-compose-pm-jdbc.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc \
		--remove-orphans
	@echo "✅ Flink stack with supporting services started successfully"
.PHONY: run-pm-jdbc

# JDBC Based Catalog, Iceberg
run-ib-jdbc:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc 

	@echo "🚀 Starting Flink stack, supporting services (PostgreSQL)... for Iceberg JDBC Catalog"
	docker compose -f docker-compose-ib-jdbc.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc \
		--remove-orphans
	@echo "✅ Flink stack with supporting services started successfully"
.PHONY: run-ib-j


# Polaris Based Catalog, Iceberg
run-ib-pol:
	@echo "🚀 Creating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc 

	@echo "🚀 Starting Flink stack, supporting services (PostgreSQL)... for Iceberg Polaris Catalog"
	docker compose -f docker-compose-ib-polaris.yml -p flussvector up -d \
		jobmanager taskmanager \
 	 	postgrescdc \
		--remove-orphans
	@echo "✅ Flink stack with supporting services started successfully"
.PHONY: run-ib-pol


stop:
	docker compose stop

start:
	docker compose start

down:	
	docker compose down
	cd data/; rm -rf flink
	cd data/; rm -rf postgrescdc

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


# File System based
master:
	@echo "-- Generated FS based master.sql" > ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.0.creCatGen.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.1.creCatPaimon-fs.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/3.1.creTargetFinflow-Paimon.sql >> ./creFlinkFlows/master.sql
	@echo "✅ master.sql for FS Storage generated"


deploy: master
	@echo "-- Deploying Paimon based Catalog with Filesystem..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/master.sql


# Single worker/single thread, outputting from flink directly to Paimon
ahs_paimon:
	@echo "-- Submitting Account Holders Embedding Job, output to Paimon..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.1.creInsertsAhSingle_paimon.sql

txns_paimon:
	@echo "-- Submitting Transaction Embedding Job, output to Paimon..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.2.creInsertsTxnSingle_paimon.sql


# Multiple workers/multiple threads
# Need to figure this out still.

