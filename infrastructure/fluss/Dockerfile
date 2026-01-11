FROM apache/fluss:0.8.0-incubating
SHELL ["/bin/bash", "-c"]

ENV FLUSS_HOME=/opt/fluss
ENV POSTGRESQL_CONNECTOR=42.7.6
ENV ICEBERG_VERSION=1.9.1

COPY stage/postgresql-42.7.6.jar           ${FLUSS_HOME}/lib/
COPY stage/iceberg-aws-bundle-1.9.1.jar    ${FLUSS_HOME}/lib/
COPY stage/iceberg-core-1.9.1.jar          ${FLUSS_HOME}/lib/
COPY stage/iceberg-common-1.9.1.jar        ${FLUSS_HOME}/lib/
COPY stage/iceberg-api-1.9.1.jar           ${FLUSS_HOME}/lib/
COPY stage/iceberg-bundled-guava-1.9.1.jar ${FLUSS_HOME}/lib/