
DELIMITER $

DROP PROCEDURE IF EXISTS `customer_get`$
CREATE PROCEDURE `customer_get`(
  IN _custId INTEGER
)
BEGIN  

  SELECT 
    c.id custId, 
    a.id addressId,
    normalize_name(c.category, c.company, c.lastname, c.firstname) custName,
    c.lastname,
    c.firstname,
    c.ctime,
    c.category,
    cc.tag companyclass,
    g.shortTag gender,
    a.location,
    a.geometry,
    a.streetname street,
    a.housenumber,
    a.streettype,
    a.streetname,
    a.additional,
    a.city,
    a.postcode
  FROM customer c
    LEFT JOIN companyClass cc ON c.type = cc.id
    INNER JOIN `address` a ON c.addressId=a.id
    LEFT JOIN gender g ON c.gender = g.id 
    WHERE c.id = _custId;
END$

DELIMITER ;
