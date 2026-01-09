
-- Paimon based Catalog stored inside PostgreSQL database using JDBC interface
-------------------------------------------------------------------------------------------------------------------------
-- server: postgrescat
-- db:     flink_catalog
-- schema: paimon_catalog
CREATE CATALOG c_paimon WITH (
     'type'                          = 'paimon'
    ,'metastore'                     = 'jdbc'                      
    ,'catalog-key'                   = 'jdbc'
    ,'uri'                           = 'jdbc:postgresql://postgrescdc:5432/catalogs?currentSchema=paimon'
    ,'jdbc.user'                     = 'dbadmin'
    ,'jdbc.password'                 = 'dbpassword'
    ,'jdbc.driver'                   = 'org.postgresql.Driver'
    ,'warehouse'                     = 's3://warehouse/paimon'      
    ,'s3.endpoint'                   = 'http://minio:9000'        
    ,'s3.path-style-access'          = 'true'                     
    ,'table-default.file.format'     = 'parquet'
);

USE CATALOG c_paimon;

-- Output from PyFlink routine, embedded tables
CREATE DATABASE IF NOT EXISTS c_paimon.finflow;         

SHOW DATABASES;


