-- Revert asr:tag-table from pg

BEGIN;

ALTER TABLE user_site_hourly DROP CONSTRAINT user_site_hourly_tag_id_fkey;
ALTER TABLE user_site_hourly DROP COLUMN tag_id;
DROP TRIGGER setmodified ON tag;
DROP TABLE tag;

COMMIT;
