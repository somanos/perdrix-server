
DELIMITER $

DROP PROCEDURE IF EXISTS `site_list`$
CREATE PROCEDURE `site_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(_page, _offset, _range);  
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;

  SELECT
    *,
    _page `page`
  FROM `site`
    WHERE custId=_custId
    ORDER BY ctime DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
