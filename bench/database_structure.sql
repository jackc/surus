CREATE EXTENSION IF NOT EXISTS hstore;

DROP TABLE IF EXISTS yaml_key_value_records;

CREATE TABLE yaml_key_value_records(
  id serial PRIMARY KEY,
  properties varchar
);


DROP TABLE IF EXISTS surus_key_value_records;

CREATE TABLE surus_key_value_records(
  id serial PRIMARY KEY,
  properties hstore
);

CREATE INDEX ON surus_key_value_records USING GIN (properties);


DROP TABLE IF EXISTS eav_detail_records;
DROP TABLE IF EXISTS eav_key_value_records;

CREATE TABLE eav_master_records(
  id serial PRIMARY KEY
);

CREATE TABLE eav_detail_records(
  id serial PRIMARY KEY,
  eav_master_record_id integer REFERENCES eav_master_records,
  "key" varchar NOT NULL,
  "value" varchar NOT NULL
);

CREATE INDEX ON eav_detail_records (eav_master_record_id);
CREATE INDEX ON eav_detail_records ("key");
CREATE UNIQUE INDEX ON eav_detail_records(eav_master_record_id, "key");
CREATE INDEX ON eav_detail_records ("value");



DROP TABLE IF EXISTS wide_records;

-- a couple indexed fields and a number of unindexed fields
CREATE TABLE wide_records(
  id serial PRIMARY KEY,
  a varchar NOT NULL,
  b varchar NOT NULL,
  c varchar NOT NULL,
  d varchar NOT NULL,
  e varchar NOT NULL,
  f varchar NOT NULL,
  g varchar NOT NULL,
  h varchar NOT NULL,
  i varchar NOT NULL,
  j varchar NOT NULL
);

CREATE INDEX ON wide_records (a);
CREATE INDEX ON wide_records (b);



DROP TABLE IF EXISTS narrow_records;

-- a one indexed fields and a couple unindexed fields
CREATE TABLE narrow_records(
  id serial PRIMARY KEY,
  a varchar NOT NULL,
  b varchar NOT NULL,
  c varchar NOT NULL
);

CREATE INDEX ON narrow_records (a);



DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users(
  id serial PRIMARY KEY,
  name varchar NOT NULL,
  email varchar NOT NULL
);



DROP TABLE IF EXISTS forums CASCADE;

CREATE TABLE forums(
  id serial PRIMARY KEY,
  name varchar NOT NULL
);



DROP TABLE IF EXISTS posts CASCADE;

CREATE TABLE posts(
  id serial PRIMARY KEY,
  forum_id integer NOT NULL REFERENCES forums,
  author_id integer NOT NULL REFERENCES users,
  subject varchar NOT NULL,
  body varchar NOT NULL
);

CREATE INDEX ON posts(forum_id);
CREATE INDEX ON posts(author_id);



DROP TABLE IF EXISTS tags CASCADE;

CREATE TABLE tags(
  id serial PRIMARY KEY,
  name varchar NOT NULL UNIQUE
);



DROP TABLE IF EXISTS posts_tags CASCADE;

CREATE TABLE posts_tags(
  post_id integer NOT NULL REFERENCES posts,
  tag_id integer NOT NULL REFERENCES tags,
  PRIMARY KEY (post_id, tag_id)
);

CREATE INDEX ON posts_tags(tag_id);
