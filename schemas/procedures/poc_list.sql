
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_list`$
CREATE PROCEDURE `poc_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER ;

  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT
    p.id,
    p.custId,
    p.siteId,
    p.role,
    g.shortTag gender,
    p.lastname,
    p.firstname,
    p.email,
    p.phones,
    p.ctime,
    p.active,
    _page `page`,
    JSON_OBJECT(
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'citycode', s.citycode,
      'city', s.city,
      'geometry', s.geometry,
      'ctime', s.ctime
    )`site`
  FROM poc p
    LEFT JOIN `site` s ON s.custId=p.custId
    LEFT JOIN customer c ON c.id = p.custId
    INNER JOIN gender g ON p.gender = g.id
    WHERE p.custId = _custId GROUP BY p.id
    LIMIT _offset ,_range;
END$

DELIMITER ;
