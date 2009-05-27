-- 
-- zeitgit - a commit log aggregation server
-- 
-- database schema (PostgreSQL)
--

CREATE ROLE commiter LOGIN ENCRYPTED PASSWORD 'password';

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
GRANT SELECT,INSERT ON commits TO commiter;

CREATE TABLE commit_branch (
  id serial NOT NULL,
  hash varchar NOT NULL REFERENCES commits(hash),
  branch varchar NOT NULL
);
GRANT SELECT,INSEET ON commit_branch TO commiter;
GRANT ALL ON commit_branch_id_seq TO commiter;
