
DELIMITER $

DROP PROCEDURE IF EXISTS `bill_get`$
CREATE PROCEDURE `bill_get`(
  IN _id INTEGER
)
BEGIN
  SELECT 
    b.*,
    b.id billId,
    JSON_OBJECT(
      'custId', s.custId,
      'countrycode', s.countrycode,
      'location', s.location,
      'postcode', s.postcode,
      'city', s.city,
      'geometry', s.geometry,
      'ctime', s.ctime,
      'statut', s.statut,
      'siteId', s.id,
      'id', s.id
    ) `site`
    FROM bill b
      INNER JOIN `site` s ON s.id=b.siteId
      WHERE b.id = _id;
END$

DELIMITER ;
