
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
      'countrycode', a.countrycode,
      'location', a.location,
      'postcode', a.postcode,
      'city', a.city,
      'geometry', a.geometry,
      'ctime', a.ctime,
      'statut', s.statut,
      'siteId', s.id,
      'id', s.id
    ) `site`
    FROM bill b
      INNER JOIN `site` s ON s.id=b.siteId
      INNER JOIN `address` a ON s.addressId=a.id
      WHERE b.id = _id;
END$

DELIMITER ;
