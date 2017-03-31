-- Verify asr:user-table on pg

BEGIN;

SELECT
   id,
   login,
   name,
   password,
   created,
   modified
   FROM
      "user"
   WHERE
      FALSE;

SELECT 1/COUNT(*)
   FROM
      information_schema.triggers
   WHERE
      event_object_table = 'user'
      AND trigger_name = 'set_modified'
      AND event_manipulation = 'INSERT'
      AND action_orientation = 'ROW'
      AND action_timing = 'BEFORE';

SELECT 1/COUNT(*)
   FROM
      information_schema.triggers
   WHERE
      event_object_table = 'user'
      AND trigger_name = 'set_modified'
      AND event_manipulation = 'UPDATE'
      AND action_orientation = 'ROW'
      AND action_timing = 'BEFORE';

ROLLBACK;
