-- Verify asr:access_log-table on pg

BEGIN;

SELECT
   ush_id,
   tag_name,
   ltime,
   elapsed,
   ip,
   code,
   status,
   bytes,
   method,
   protocol,
   host,
   site,
   port,
   url,
   ruser,
   peerstatus,
   peerhost,
   mime_type
   FROM
      access_log
   WHERE
      FALSE;

ROLLBACK;
