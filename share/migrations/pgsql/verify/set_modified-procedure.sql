-- Verify asr:set_modified on pg

BEGIN;

SELECT has_function_privilege('set_modified()', 'execute');

ROLLBACK;
