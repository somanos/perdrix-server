
DELIMITER $

DROP PROCEDURE IF EXISTS `site_list_poc`$
CREATE PROCEDURE `site_list_poc`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER ;
  DECLARE _siteId INTEGER ;

  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT
    sp.pocId,
    c.id custId,
    s.id siteId,
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
    )`site`,
    JSON_OBJECT(
      'countrycode', c.countrycode,
      'location', c.location,
      'postcode', c.postcode,
      'citycode', c.citycode,
      'city', c.city,
      'geometry', c.geometry,
      'ctime', c.ctime,
      'custName', normalize_name(c.category, c.company, c.lastname, c.firstname)
    )`customer`
  FROM site_poc sp
    INNER JOIN `site` s ON s.id=sp.siteId
    INNER JOIN customer c ON c.id = sp.custId
    INNER JOIN poc p ON p.id=sp.pocId
    INNER JOIN gender g ON p.gender = g.id
    WHERE sp.siteId = _siteId GROUP BY p.id
    ORDER BY sp.ctime DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
