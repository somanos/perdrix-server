
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_get`$
CREATE PROCEDURE `poc_get`(
  IN _id INTEGER
)
BEGIN  

  SELECT 
    p.id,
    s.custId, 
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
    JSON_OBJECT(
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'citycode', s.citycode,
      'city', s.city,
      'geometry', s.geometry,
      'ctime', s.ctime
    ) `site`
  FROM poc p
    INNER JOIN `site` s ON s.custId=p.custId AND p.siteId=s.id
    LEFT JOIN gender g ON p.gender = g.id
    WHERE p.id = _id;
END$

DELIMITER ;
