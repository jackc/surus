CREATE EXTENSION IF NOT EXISTS hstore;

DROP TABLE IF EXISTS hstore_records;

CREATE TABLE hstore_records(
  id serial PRIMARY KEY,
  properties hstore
);

