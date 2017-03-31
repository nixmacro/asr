-- Deploy asr:materialize_user_site_hourly to pg
-- requires: user_site_hourly-table
-- requires: access_log-table

BEGIN;

CREATE OR REPLACE FUNCTION materialize_user_site_hourly(boolean, date, date) RETURNS integer
LANGUAGE plpgsql
AS $_$
DECLARE
   keep_detail ALIAS FOR $1;
   start_date ALIAS FOR $2;
   end_date ALIAS FOR $3;
   affected_rows INT := 0;
   affected_tmp INT := 0;
BEGIN
   WHILE start_date <= end_date LOOP
      SELECT materialize_user_site_hourly(keep_detail, start_date) INTO affected_tmp;
      affected_rows := affected_rows + affected_tmp;
      start_date := start_date + 1;
   END LOOP;

   RETURN affected_rows;
END;
$_$;

CREATE OR REPLACE FUNCTION materialize_user_site_hourly(boolean, date) RETURNS integer
LANGUAGE plpgsql
AS $_$
DECLARE
   keep_detail ALIAS FOR $1;
   relevant_day ALIAS FOR $2;
   affected_rows INT := 0;
BEGIN
   -- First create non-existent tags if any
   INSERT INTO tag(name)
      SELECT
         DISTINCT a.tag_name
      FROM
         access_log a
         LEFT JOIN tag t ON (a.tag_name = t.name)
      WHERE
         t.name IS NULL;

   -- Then summarize the reqested day
   INSERT INTO user_site_hourly(tag_id,local_time,remote_user,site,total_time,total_bytes)
      SELECT
         t.id AS tag_id,
         date_trunc('hour', a.ltime) AS local_time,
         COALESCE(a.ruser, HOST(ip)) AS remote_user,
         a.site AS site,
         SUM(a.elapsed) AS total_time,
         SUM(a.bytes) AS total_bytes
      FROM
         access_log a
         JOIN tag t ON (a.tag_name = t.name)
      WHERE
         date_trunc('day', a.ltime) = relevant_day
         AND a.code <> 'TCP_DENIED'
         AND a.code LIKE 'TCP_%'
      GROUP BY
         tag_id,
         local_time,
         remote_user,
         site
      ORDER BY
         tag_id,
         local_time,
         remote_user,
         site,
         total_time,
         total_bytes;

   -- Finally do something with the raw data
   IF keep_detail THEN
      -- If requested, created a relation between the raw data and it's parent summarization
      UPDATE
         access_log AS al
      SET
         ush_id = ush.id
      FROM
         user_site_hourly AS ush
      WHERE
         (date_trunc('hour', local_time) = date_trunc('hour', ltime))
         AND (al.site = ush.site) AND (COALESCE(ruser,HOST(ip)) = ush.remote_user)
         AND (date_trunc('day', ltime) = relevant_day);
   ELSE
      -- Otherwise throw the data away
      DELETE FROM access_log WHERE date_trunc('day', ltime) = relevant_day;
   END IF;

   GET DIAGNOSTICS affected_rows = ROW_COUNT;
   RETURN affected_rows;
END;
$_$;

COMMIT;
