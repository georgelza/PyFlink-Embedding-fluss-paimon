.DEFAULT_GOAL := help
include ../.env

FLUSS_VERSION_FULL=0.8.0

IMAGE_NAME=fluss_0.8.0-incubating
VERSION=1.0.0

define HELP

Available commands:

- pull:  Pull/wget all jar's

- build: Build this project

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build: 
	@echo "🔨 Building Apache Fluss 0.8.0 Docker images..."
	docker build --build-arg REPO_NAME=${REPO_NAME} -t ${REPO_NAME}/${IMAGE_NAME}:${VERSION} --file Dockerfile . --no-cache
	@echo "✅ Apache Fluss Docker image built ${IMAGE_NAME}:${VERSION} successfully"


pull: paimon s3

# Required for Paimon and JDBC catalog.
paimom:
	cd stage; wget https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.6/postgresql-42.7.6.jar \
	cd stage; wget https://repo1.maven.org/maven2/org/apache/paimon/paimon-bundle/1.3.1/paimon-bundle-1.3.1.jar 

# Required for Paimon Lakehouse to S3
s3:
 	cd stage; wget https://repo1.maven.org/maven2/org/apache/paimon/paimon-s3/1.3.1/paimon-s3-1.3.1.jar 