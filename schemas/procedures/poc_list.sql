
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_list`$
CREATE PROCEDURE `poc_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;

  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT
    p.id pocId,
    p.role,
    g.shortTag gender,
    p.lastname,
    p.firstname,
    p.email,
    p.phones,
    p.ctime,
    p.active,
    _page `page`
  FROM poc p
    INNER JOIN gender g ON p.gender = g.id
    LIMIT _offset ,_range;
END$

DELIMITER ;
