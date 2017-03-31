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

SELECT 1/COUNT(*)
   FROM
      information_schema.triggers
   WHERE
      event_object_table = 'tag'
      AND trigger_name = 'set_modified'
      AND event_manipulation = 'INSERT'
      AND action_orientation = 'ROW'
      AND action_timing = 'BEFORE';

SELECT 1/COUNT(*)
   FROM
      information_schema.triggers
   WHERE
      event_object_table = 'tag'
      AND trigger_name = 'set_modified'
      AND event_manipulation = 'UPDATE'
      AND action_orientation = 'ROW'
      AND action_timing = 'BEFORE';

ROLLBACK;
