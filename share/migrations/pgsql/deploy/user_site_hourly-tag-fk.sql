-- Deploy asr:user_site_hourly-tag-fk to pg
-- requires: user_site_hourly-table

BEGIN;

   ALTER TABLE user_site_hourly DROP CONSTRAINT "user_site_hourly_tag_id_fkey";
   ALTER TABLE user_site_hourly ADD CONSTRAINT "user_site_hourly-tag_fkey" FOREIGN KEY (tag_id) REFERENCES tag(id) DEFERRABLE INITIALLY DEFERRED;

COMMIT;
