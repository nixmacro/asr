-- Deploy asr:tag-table to pg
-- requires: setmodified
-- requires: user_site_hourly-table

BEGIN;

CREATE TABLE tag (
   id SERIAL NOT NULL PRIMARY KEY,
   name VARCHAR(32) NOT NULL UNIQUE,
   info VARCHAR,
   created TIMESTAMP without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
   modified TIMESTAMP without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER setmodified BEFORE INSERT OR UPDATE ON tag FOR EACH ROW EXECUTE PROCEDURE setmodified();

ALTER TABLE user_site_hourly ADD COLUMN tag_id INT;
ALTER TABLE user_site_hourly ADD CONSTRAINT user_site_hourly_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES tag(id);

COMMIT;
