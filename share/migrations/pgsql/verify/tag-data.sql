-- Verify asr:tag-data on pg

BEGIN;

SELECT 1/COUNT(*)
   FROM
      tag
   WHERE
      id = 0
      AND name = 'default'
      AND info = 'All data will be tagged with this unless specified otherwise.'
      AND created <= CURRENT_TIMESTAMP
      AND modified <= CURRENT_TIMESTAMP;

ROLLBACK;
