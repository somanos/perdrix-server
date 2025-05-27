
DELIMITER $

DROP PROCEDURE IF EXISTS `customer_get`$
CREATE PROCEDURE `customer_get`(
  IN _custId INTEGER
)
BEGIN  

  SELECT 
    c.id custId, 
    normalize_name(c.category, c.company, c.lastname, c.firstname) custName,
    c.ctime,
    c.category,
    cc.tag companyclass,
    g.shortTag gender,
    c.location,
    JSON_VALUE(c.location, "$[0]") housenumber,
    JSON_VALUE(c.location, "$[1]") streettype,
    JSON_VALUE(c.location, "$[2]") streetname,
    JSON_VALUE(c.location, "$[3]") additional,
    c.city,
    c.postcode
  FROM customer c
    LEFT JOIN companyClass cc ON c.type = cc.id
    LEFT JOIN gender g ON c.gender = g.id
    WHERE c.id = _custId;
END$

DELIMITER ;
