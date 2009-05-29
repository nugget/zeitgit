-- 
-- zeitgit - a commit log aggregation server
-- 
-- database schema (PostgreSQL)
--

CREATE ROLE committer LOGIN ENCRYPTED PASSWORD 'password';

CREATE TABLE commits (
  hash varchar NOT NULL,
  tree_hash varchar NOT NULL,
  parent_hash varchar NOT NULL,
  author_name varchar,
  author_email varchar,
  author_date timestamp,
  commit_name varchar,
  commit_email varchar,
  commit_date timestamp,
  subject varchar,
  body varchar,
  added timestamp NOT NULL DEFAULT (current_timestamp at time zone 'utc'),
  PRIMARY KEY(hash)
);
GRANT SELECT,INSERT ON commits TO committer;

CREATE TABLE commit_location (
  id serial NOT NULL,
  hash varchar NOT NULL REFERENCES commits(hash),
  branch varchar NOT NULL,
  hostname varchar,
  origin varchar,
  path varchar,
  version numeric(4,2),
  PRIMARY KEY(id)
);
GRANT SELECT,INSERT ON commit_location TO committer;
GRANT ALL ON commit_location_id_seq TO committer;
