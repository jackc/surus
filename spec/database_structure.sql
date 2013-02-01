CREATE EXTENSION IF NOT EXISTS hstore;

DROP TABLE IF EXISTS hstore_records;

CREATE TABLE hstore_records(
  id serial PRIMARY KEY,
  properties hstore
);



DROP TABLE IF EXISTS text_array_records;

CREATE TABLE text_array_records(
  id serial PRIMARY KEY,
  texts text[]
);



DROP TABLE IF EXISTS integer_array_records;

CREATE TABLE integer_array_records(
  id serial PRIMARY KEY,
  integers integer[]
);



DROP TABLE IF EXISTS float_array_records;

CREATE TABLE float_array_records(
  id serial PRIMARY KEY,
  floats float[]
);



DROP TABLE IF EXISTS decimal_array_records;

CREATE TABLE decimal_array_records(
  id serial PRIMARY KEY,
  decimals decimal[]
);



DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users(
  id serial PRIMARY KEY,
  name varchar NOT NULL,
  email varchar NOT NULL
);



DROP TABLE IF EXISTS posts CASCADE;

CREATE TABLE posts(
  id serial PRIMARY KEY,
  author_id integer NOT NULL REFERENCES users,
  subject varchar NOT NULL,
  body varchar NOT NULL
);

