
DELIMITER $

DROP PROCEDURE IF EXISTS `quote_get`$
CREATE PROCEDURE `quote_get`(
  IN _id INTEGER
)
BEGIN
  SELECT 
    q.*,
    q.id quoteId,
    JSON_OBJECT(
      'custId', s.custId,
      'countrycode', a.countrycode,
      'location', a.location,
      'postcode', a.postcode,
      'city', a.city,
      'geometry', a.geometry,
      'ctime', s.ctime,
      'statut', s.statut,
      'siteId', s.id,
      'id', s.id
    ) `site`
    FROM `quote` q
      INNER JOIN `site` s ON s.id=q.siteId
      INNER JOIN `address` a ON s.addressId=a.id
      WHERE q.id = _id;
END$

DELIMITER ;
