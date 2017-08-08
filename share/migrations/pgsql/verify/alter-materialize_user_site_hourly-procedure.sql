-- Verify asr:change-materialize_user_site_hourly-procedure on pg

BEGIN;

SELECT has_function_privilege('materialize_user_site_hourly(date, date, boolean, varchar)', 'execute');
SELECT has_function_privilege('materialize_user_site_hourly(date, boolean, varchar)', 'execute');

ROLLBACK;
