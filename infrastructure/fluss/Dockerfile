FROM apache/fluss:0.8.0-incubating
SHELL ["/bin/bash", "-c"]

ENV FLUSS_HOME=/opt/fluss
ENV POSTGRESQL_CONNECTOR=42.7.6

COPY stage/postgresql-${POSTGRESQL_CONNECTOR}.jar  ${FLUSS_HOME}/lib/
