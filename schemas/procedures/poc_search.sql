
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_search`$
CREATE PROCEDURE `poc_search`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _words TEXT;
  DECLARE _key TEXT;

  
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), '.+') INTO _words;
  SELECT IFNULL(JSON_VALUE(_args, "$.key"), 'key') INTO _key;
  CALL yp.pageToLimits(_page, _offset, _range);  
  IF _words REGEXP "^ *([0-9]{1,}[ \.\-]+){1,}" THEN
    SELECT REGEXP_REPLACE(_words, "[ \.\-]+", "") INTO _words;
  END IF;
  SELECT
    DISTINCT p.id pocId, 
    p.role,
    g.longTag gender,
    p.firstname,
    p.lastname,
    p.email,
    p.phones,
    p.ctime,
    p.active
  FROM poc p
    LEFT JOIN gender g ON p.gender = g.id
    WHERE (CASE 
      WHEN _key='lastname' THEN
        lastname REGEXP _words
      WHEN _key='firstname' THEN
        firstname REGEXP _words
      WHEN _key='email' THEN
        email REGEXP _words
      WHEN _key='office' THEN
        REGEXP_REPLACE(JSON_VALUE(phones, "$[0]"), "[ \.\-]+", "") REGEXP _words
      WHEN _key='home' THEN
        REGEXP_REPLACE(JSON_VALUE(phones, "$[1]"), "[ \.\-]+", "") REGEXP _words
      WHEN _key='mobile' THEN
        REGEXP_REPLACE(JSON_VALUE(phones, "$[2]"), "[ \.\-]+", "") REGEXP _words
      WHEN _key='fax' THEN
        REGEXP_REPLACE(JSON_VALUE(phones, "$[3]"), "[ \.\-]+", "") REGEXP _words
    END)
  LIMIT _offset ,_range;
END$

DELIMITER ;
