
DELIMITER $

DROP PROCEDURE IF EXISTS `site_get_poc`$
CREATE PROCEDURE `site_get_poc`(
  IN _pocId INTEGER
)
BEGIN
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
    JSON_OBJECT(
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'citycode', s.citycode,
      'city', s.city,
      'geometry', s.geometry,
      'ctime', s.ctime
    )`site`
  FROM site_poc sp
    INNER JOIN `site` s ON s.id=sp.siteId
    INNER JOIN customer c ON c.id = sp.custId
    INNER JOIN poc p ON p.id=sp.pocId
    INNER JOIN gender g ON p.gender = g.id
    WHERE sp.pocId = _pocId;
END$

DELIMITER ;
