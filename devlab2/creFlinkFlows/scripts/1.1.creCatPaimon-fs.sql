
-- Paimon based Catalog stored inside PostgreSQL database using JDBC interface
-------------------------------------------------------------------------------------------------------------------------
-- server: postgrescat
-- db:     catalogs
-- schema: paimon_jdbc
CREATE CATALOG c_paimon WITH (
     'type'                          = 'paimon'
    ,'metastore'                     = 'jdbc'                      
    ,'catalog-key'                   = 'jdbc'
    ,'uri'                           = 'jdbc:postgresql://postgrescdc:5432/catalogs?currentSchema=paimon_jdbc'
    ,'jdbc.user'                     = 'dbadmin'
    ,'jdbc.password'                 = 'dbpassword'
    ,'jdbc.driver'                   = 'org.postgresql.Driver'
    ,'warehouse'                     = 'file:///tmp/paimon'
    ,'table-default.file.format'     = 'parquet'
);

USE CATALOG c_paimon;

-- Output from PyFlink routine, embedded tables
CREATE DATABASE IF NOT EXISTS c_paimon.finflow;       

SHOW DATABASES;