-- Verify asr:tag-table on pg

BEGIN;

SELECT
   id,
   name,
   info,
   created,
   modified
   FROM
      tag
   WHERE
      FALSE;

SELECT
   tag_id
   FROM
      user_site_hourly
   WHERE
      FALSE;

SELECT 1/COUNT(*)
   FROM information_schema.triggers
   WHERE event_object_table = 'tag'
      AND trigger_name = 'setmodified'
      AND event_manipulation = 'INSERT'
      AND action_orientation = 'ROW'
      AND action_timing = 'BEFORE';

SELECT 1/COUNT(*)
   FROM information_schema.triggers
   WHERE event_object_table = 'tag'
      AND trigger_name = 'setmodified'
      AND action_orientation = 'ROW'
      AND action_timing = 'BEFORE'
      AND event_manipulation = 'UPDATE';

SELECT 1/COUNT(*)
   FROM information_schema.table_constraints
   WHERE table_name = 'user_site_hourly'
      AND constraint_name = 'user_site_hourly_tag_id_fkey'
      AND constraint_type = 'FOREIGN KEY';

ROLLBACK;
