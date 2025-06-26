
DELIMITER $

DROP PROCEDURE IF EXISTS `site_get`$
CREATE PROCEDURE `site_get`(
  IN _id INTEGER
)
BEGIN
  SELECT 
    s.*,
    s.id siteId,
    normalize_name(c.category, c.company, c.lastname, c.firstname) custName,
    a.location,
    a.geometry,
    a.city,
    a.postcode,
    JSON_OBJECT(
      'id', c.id,
      'custId', c.id,
      'gender', g.shortTag,
      'companyclass', cc.tag,
      'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
      'location', ca.location,
      'geometry', ca.geometry,
      'city', ca.city,
      'postcode', ca.postcode
    ) customer

    FROM `site` s
      INNER JOIN customer c ON c.id=s.custId
      INNER JOIN `address` a ON s.addressId=a.id
      INNER JOIN `address` ca ON c.addressId=ca.id
      LEFT JOIN gender g ON g.id=c.gender
      LEFT JOIN companyClass cc ON c.type = cc.id
      WHERE s.id = _id;
END$

DELIMITER ;
