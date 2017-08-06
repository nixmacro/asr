-- Verify asr:user_site_hourly-tag-fk on pg

BEGIN;

SELECT 1/COUNT(*)
   FROM
      information_schema.table_constraints
   WHERE
      table_name = 'user_site_hourly'
      AND constraint_name = 'user_site_hourly-tag_fkey'
      AND constraint_type = 'FOREIGN KEY';

ROLLBACK;
