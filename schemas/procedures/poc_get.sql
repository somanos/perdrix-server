
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_get`$
CREATE PROCEDURE `poc_get`(
  IN _id INTEGER
)
BEGIN  

  SELECT 
    p.id,
    c.id custId, 
    COALESCE(s.id, c.id) siteId, 
    CONCAT(p.lastname, IF(p.firstname != '', CONCAT(' ', p.firstname), '')) pocName,
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
    INNER JOIN `site` s ON s.custId=p.custId AND p.siteId=s.id
    INNER JOIN customer c ON c.id = p.custId
    LEFT JOIN gender g ON p.gender = g.id
    WHERE p.id = _id;
END$

DELIMITER ;
