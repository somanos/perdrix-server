
DELIMITER $

DROP PROCEDURE IF EXISTS `customer_search`$
CREATE PROCEDURE `customer_search`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _type VARCHAR(20) DEFAULT 'person';
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _words TEXT;

  
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), '.+') INTO _words;
  SELECT IFNULL(JSON_VALUE(_args, "$.type"), '.+') INTO _type;
  CALL yp.pageToLimits(_page, _offset, _range);  

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
    WHERE IF(_type='company', c.company REGEXP _words, CONCAT(c.lastname, ' ', c.firstname)  REGEXP _words)
  LIMIT _offset ,_range;
END$

DELIMITER ;
