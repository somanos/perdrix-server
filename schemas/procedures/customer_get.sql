
DELIMITER $

DROP PROCEDURE IF EXISTS `customer_get`$
CREATE PROCEDURE `customer_get`(
  IN _args JSON
)
BEGIN  DECLARE _custId INTEGER ;

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;


  SELECT 
    c.id custId, 
    IF(c.category=0, c.company, CONCAT(c.lastname, IF(c.firstname != '', CONCAT(' ', c.firstname), ''))) custName,
    c.ctime,
    c.category,
    cc.tag companyclass,
    g.shortTag gender,
    c.location,
    JSON_VALUE(c.location, "$[2]") street,
    c.city,
    c.postcode
  FROM customer c
    LEFT JOIN companyClass cc ON c.type = cc.id
    LEFT JOIN gender g ON c.gender = g.id
    WHERE c.id = _custId;
END$

DELIMITER ;
