
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
    IF(p.siteType='site',
      JSON_OBJECT(
        'countrycode', s.countrycode,
        'location', s.location,
        'postcode', s.postcode,
        'citycode', s.citycode,
        'city', s.city,
        'geometry', s.geometry,
        'ctime', s.ctime
      ),
      JSON_OBJECT(
        'countrycode', c.countrycode,
        'location', c.location,
        'postcode', c.postcode,
        'citycode', c.citycode,
        'city', c.city,
        'geometry', c.geometry,
        'ctime', c.ctime
      )
    ) `site`
  FROM poc p
    LEFT JOIN `site` s ON s.custId=p.custId
    LEFT JOIN customer c ON c.id = p.custId
    INNER JOIN gender g ON p.gender = g.id
    WHERE p.custId = _custId
    LIMIT _offset ,_range;
END$

DELIMITER ;
