-- Deploy asr:tag-table to pg
-- requires: set_modified-procedure

BEGIN;

CREATE TABLE tag (
   id SERIAL NOT NULL PRIMARY KEY,
   name VARCHAR(32) NOT NULL UNIQUE,
   info VARCHAR,
   created TIMESTAMP without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
   modified TIMESTAMP without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER set_modified BEFORE INSERT OR UPDATE ON tag FOR EACH ROW EXECUTE PROCEDURE set_modified();

COMMIT;
