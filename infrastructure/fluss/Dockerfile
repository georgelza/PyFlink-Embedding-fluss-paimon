FROM apache/fluss:0.8.0-incubating
SHELL ["/bin/bash", "-c"]

ENV FLUSS_HOME=/opt/fluss

# Required for JDBC catalog
RUN mkdir -p /opt/fluss/plugins/common
COPY stage/postgresql-42.7.6.jar            ${FLUSS_HOME}/plugins/common

# Required for Paimon / JDBC catalog
RUN mkdir -p /opt/fluss/plugins/paimon
COPY stage/paimon-bundle-1.3.1.jar          ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-core-1.3.1.jar            ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-common-1.3.1.jar          ${FLUSS_HOME}/plugins/paimon

# Required for Iceberg / JDBC catalog
# See Option 2, https://fluss.apache.org/docs/next/streaming-lakehouse/integrate-data-lakes/iceberg/#2-custom-catalog-implementations
# Required for Iceberg: https://fluss.apache.org/docs/next/streaming-lakehouse/integrate-data-lakes/iceberg/#configure-iceberg-in-cluster-configurations

RUN mkdir -p /opt/fluss/plugins/iceberg
COPY stage/iceberg-core-1.9.1.jar           ${FLUSS_HOME}/plugins/iceberg
COPY stage/hadoop-apache-3.3.5-2.jar        ${FLUSS_HOME}/plugins/iceberg

RUN chown -R fluss:fluss ${FLUSS_HOME}