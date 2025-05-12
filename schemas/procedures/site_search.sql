
DELIMITER $

DROP PROCEDURE IF EXISTS `site_search`$
CREATE PROCEDURE `site_search`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _words TEXT;
  DECLARE _custId INTEGER;

  
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), '.+') INTO _words;
  SELECT IFNULL(JSON_VALUE(_args, "$.custId"), 0) INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(_page, _offset, _range);  

  SELECT 
    s.*,
    _page `page`,
    JSON_VALUE(s.location, "$[2]") street
    FROM `site` s
      HAVING s.custId=_custId AND 
      (street REGEXP _words OR s.city REGEXP _words)
    LIMIT _offset ,_range;

END$

DELIMITER ;
