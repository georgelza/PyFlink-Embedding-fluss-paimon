FROM apache/fluss:0.8.0-incubating
SHELL ["/bin/bash", "-c"]

ENV FLUSS_HOME=/opt/fluss
ENV POSTGRESQL_CONNECTOR=42.7.6
ENV ICEBERG_VERSION=1.9.1

# Library to rech datastore
COPY stage/postgresql-42.7.6.jar           ${FLUSS_HOME}/lib/

# Contains the jdbc interface
# See Option 2, https://fluss.apache.org/docs/next/streaming-lakehouse/integrate-data-lakes/iceberg/#2-custom-catalog-implementations
COPY stage/iceberg-core-1.9.1.jar           ${FLUSS_HOME}/plugins/iceberg

# COPY stage/iceberg-aws-bundle-1.9.1.jar    ${FLUSS_HOME}/lib/
# COPY stage/iceberg-common-1.9.1.jar        ${FLUSS_HOME}/lib/
# COPY stage/iceberg-api-1.9.1.jar           ${FLUSS_HOME}/lib/
# COPY stage/iceberg-bundled-guava-1.9.1.jar ${FLUSS_HOME}/lib/

# Required for Iceberg: https://fluss.apache.org/docs/next/streaming-lakehouse/integrate-data-lakes/iceberg/#configure-iceberg-in-cluster-configurations
RUN mkdir -p /opt/fluss/plugins/iceberg
COPY stage/hadoop-apache-3.3.5-2.jar        ${FLUSS_HOME}/plugins/iceberg