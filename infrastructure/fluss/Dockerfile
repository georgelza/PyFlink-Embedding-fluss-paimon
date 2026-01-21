FROM apache/fluss:0.8.0-incubating
SHELL ["/bin/bash", "-c"]

ENV FLUSS_HOME=/opt/fluss


# 1. Paimon / JDBC catalog
RUN mkdir -p /opt/fluss/plugins/paimon
COPY stage/postgresql-42.7.6.jar            ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-bundle-1.3.1.jar          ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-s3-1.3.1.jar              ${FLUSS_HOME}/plugins/paimon

# 2. Fluss -> S3 Lakehouse tiering
RUN mv ${FLUSS_HOME}/plugins/s3/fluss-fs-s3-0.8.0-incubating.jar  ${FLUSS_HOME}/lib
RUN rm -rf ${FLUSS_HOME}/plugins/s3

# 3. Lets make sure with our copying of JARs that all is owned by the right user/group.
RUN chown -R fluss:fluss ${FLUSS_HOME}