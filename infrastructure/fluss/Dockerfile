FROM apache/fluss:0.8.0-incubating
SHELL ["/bin/bash", "-c"]

ENV FLUSS_HOME=/opt/fluss


# 1. Paimon / JDBC catalog
RUN mkdir -p /opt/fluss/plugins/paimon
COPY stage/postgresql-42.7.6.jar            ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-bundle-1.3.1.jar          ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-core-1.3.1.jar            ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-common-1.3.1.jar          ${FLUSS_HOME}/plugins/paimon


# 2. S3 DEPENDENCIES
RUN mkdir -p ${FLUSS_HOME}/plugins/s3
COPY stage/hadoop-aws-3.3.4.jar             ${FLUSS_HOME}/plugins/s3/
COPY stage/aws-java-sdk-bundle-1.12.262.jar ${FLUSS_HOME}/plugins/s3/
COPY stage/paimon-s3-1.3.1.jar              ${FLUSS_HOME}/plugins/s3/

RUN chown -R fluss:fluss ${FLUSS_HOME}