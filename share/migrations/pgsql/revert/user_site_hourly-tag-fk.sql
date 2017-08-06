-- Revert asr:user_site_hourly-tag-fk from pg

BEGIN;

   ALTER TABLE user_site_hourly DROP CONSTRAINT "user_site_hourly-tag_fkey";
   ALTER TABLE user_site_hourly ADD CONSTRAINT user_site_hourly_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES tag(id);

COMMIT;
