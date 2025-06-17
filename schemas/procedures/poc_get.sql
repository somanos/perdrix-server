
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_get`$
CREATE PROCEDURE `poc_get`(
  IN _id INTEGER
)
BEGIN  

  SELECT 
    p.id pocId,
    s.custId, 
    s.id siteId, 
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
      'countrycode', a.countrycode,
      'location', a.location,
      'postcode', a.postcode,
      'city', a.city,
      'geometry', a.geometry,
      'ctime', a.ctime
    ) `site`
  FROM poc p
    INNER JOIN `site` s ON s.custId=p.custId AND p.siteId=s.id
    INNER JOIN `address` a ON s.addressId=s.id AND sa.catetegory='site'
    LEFT JOIN gender g ON p.gender = g.id
    WHERE p.id = _id;
END$

DELIMITER ;
