
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
    FROM `quotation` q
      INNER JOIN `site` s ON s.id=q.siteId
      WHERE q.id = _id;
END$

DELIMITER ;
