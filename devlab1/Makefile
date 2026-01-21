
.DEFAULT_GOAL := help
include .env

define HELP

Available commands:

- build: 		Build required Docker images (Flink with CDC)

- run:   		Start All services -> Paimon, JDBC based Catalog, MinIO/S3 based Lakehouse Storage, PostgreSQL DB's

- deploy:		Deploy all structures

- ahs 			Deploy insert statement for accountHolder data feed into Fluss datastore
- txns			Deploy insert statement for transaction data feed into Fluss datastore

- tier			Kick off Fluss Tiering Job - Paimon Lakehouse storage on MinIO/S3 with JDBC Catalog

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

run:
	@echo "🚀 Precreating Required volumes..."
	mkdir -p ./data/flink/logs ./data/flink/checkpoints ./data/flink/rocksdb
	mkdir -p ./data/postgrescdc ./data/postgrescat	
	mkdir -p ./data/fluss
	mkdir -p ./data/zk/data ./data/zk/datalogs
	mkdir -p ./data/minio

	@echo "🚀 Starting Flink & Fluss stack"
	@echo "   for Paimon on MinIO/S3 with JDBC Catalog"
	@echo "   & supporting services (PostgreSQL, MinIO)"
	@echo ""
	docker compose -f docker-compose.yml -p flussvector up -d \
		jobmanager taskmanager \
		zookeeper \
 	    postgrescdc postgrescat \
		coordinator-server tablet-server-1 tablet-server-2 tablet-server-3 \
		minio minio-client \
		--remove-orphans
	@echo "✅ Flink & Fluss stack with supporting services started successfully"
.PHONY: run-jdbc


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
	cd data/; rm -rf paimon
	cd data/; rm -rf minio

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


# MinIO/S3 based Storage ofr Lakehouse
master:
	@echo "-- Generated MinIO/S3 based master.sql" > ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.0.creCatGen.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/1.2.creCatFluss.sql >> ./creFlinkFlows/master.sql
	@cat ./creFlinkFlows/scripts/3.1.creTargetFinflow.sql >> ./creFlinkFlows/master.sql
	@echo "✅ master.sql for MinIO/S3 Storage generated"


deploy: master
	@echo "-- Deploying Fluss & Paimon JDBC based Catalog with MinIO/S3 storage..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/master.sql


# Single worker/sing thread, outputting from Flink to Fluss and down into Lakehouse tier
ahs:
	@echo "-- Submitting Account Holders Embedding Job, output to Fluss..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.1.creInsertsAhSingle.sql

txns:
	@echo "-- Submitting Transaction Embedding Job, output to Fluss..."
	docker compose exec --interactive --tty jobmanager /opt/flink/bin/sql-client.sh -f /creFlinkFlows/scripts/4.2.creInsertsTxnSingle.sql


# Multiple workers/multiple threads
# Need to figure this out still.


# https://fluss.apache.org/docs/maintenance/tiered-storage/lakehouse-storage/#enable-lakehouse-storage	
tier:
	@echo "-- Submitting Paimon Tiering Job->JDBC Catalog..."
	docker compose exec --interactive --tty jobmanager \
		/opt/flink/bin/flink run \
			-Dpipeline.name="My Fluss Tiering Service, output to Paimon" \
			-Dparallelism.default=2 \
			/opt/flink/lib/fluss-flink-tiering-0.8.0-incubating.jar \
			--fluss.bootstrap.servers coordinator-server:9123 \
			--datalake.format paimon \
			--datalake.paimon.type paimon \
			--datalake.paimon.metastore jdbc \
			--datalake.paimon.catalog-key jdbc \
			--datalake.paimon.uri jdbc:postgresql://postgrescat:5432/catalogs?currentSchema=paimon_jdbc \
			--datalake.paimon.jdbc.user dbadmin \
			--datalake.paimon.jdbc.password dbpassword \
			--datalake.paimon.jdbc.driver org.postgresql.Driver \
          	--datalake.paimon.warehouse s3://${MINIO_BUCKET}/paimon \
			--datalake.paimon.s3.endpoint http://minio:9000 \
			--datalake.paimon.s3.access-key mnadmin \
			--datalake.paimon.s3.secret-key mnpassword \
			--datalake.paimon.s3.path.style.access true