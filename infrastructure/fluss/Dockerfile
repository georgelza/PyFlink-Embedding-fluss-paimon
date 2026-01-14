FROM apache/fluss:0.8.0-incubating
SHELL ["/bin/bash", "-c"]

ENV FLUSS_HOME=/opt/fluss


# Required for Paimon / JDBC catalog
RUN mkdir -p /opt/fluss/plugins/paimon
COPY stage/postgresql-42.7.6.jar            ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-bundle-1.3.1.jar          ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-core-1.3.1.jar            ${FLUSS_HOME}/plugins/paimon
COPY stage/paimon-common-1.3.1.jar          ${FLUSS_HOME}/plugins/paimon

RUN chown -R fluss:fluss ${FLUSS_HOME}