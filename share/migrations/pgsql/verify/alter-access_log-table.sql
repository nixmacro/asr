-- Verify asr:alter-access_log-table on pg

BEGIN;

   SELECT 1/COUNT(*)
      FROM
         information_schema.columns
      WHERE
         table_name = 'access_log'
         AND column_name = 'host'
         AND is_nullable = 'YES';

   SELECT 1/COUNT(*)
      FROM
         information_schema.columns
      WHERE
         table_name = 'access_log'
         AND column_name = 'site'
         AND is_nullable = 'YES';

ROLLBACK;
