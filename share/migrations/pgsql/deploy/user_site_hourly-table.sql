-- Deploy asr:user_site_hourly-table to pg
-- requires: tag-table

BEGIN;

CREATE TABLE user_site_hourly (
   id BIGSERIAL NOT NULL PRIMARY KEY,
   tag_id INT NOT NULL,
   local_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
   remote_user VARCHAR NOT NULL,
   site VARCHAR NOT NULL,
   total_time BIGINT NOT NULL,
   total_bytes BIGINT NOT NULL
);

ALTER TABLE user_site_hourly ADD CONSTRAINT user_site_hourly_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES tag(id);

COMMIT;
