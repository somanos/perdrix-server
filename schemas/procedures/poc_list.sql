
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
    p.category,
    g.shortTag gender,
    p.lastname,
    p.firstname,
    p.email,
    p.phones,
    p.ctime,
    p.actif,
    JSON_OBJECT(
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'city', s.city,
      'lat', s.lat,
      'lon', s.lon,
      'ctime', s.ctime,
      'statut', s.statut
    ) `site`
  FROM poc p
    INNER JOIN `site` s ON s.custId=p.custId AND p.siteId=s.id
    LEFT JOIN gender g ON p.gender = g.id
    WHERE p.custId = _custId
    LIMIT _offset ,_range;
END$

DELIMITER ;
