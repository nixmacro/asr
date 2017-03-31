-- Verify asr:user_site_hourly-table on pg

BEGIN;

SELECT
   id,
   local_time,
   remote_user,
   site,
   total_time,
   total_bytes
   FROM
      user_site_hourly
   WHERE
      FALSE;

SELECT 1/COUNT(*)
   FROM
      information_schema.table_constraints
   WHERE
      table_name = 'user_site_hourly'
      AND constraint_name = 'user_site_hourly_tag_id_fkey'
      AND constraint_type = 'FOREIGN KEY';

ROLLBACK;
