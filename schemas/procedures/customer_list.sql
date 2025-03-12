
DELIMITER $

DROP PROCEDURE IF EXISTS `customer_list`$
CREATE PROCEDURE `customer_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _words TEXT;

  
  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), '.+') INTO _words;
  CALL yp.pageToLimits(_page, _offset, _range);  

  SELECT 
    c.id clientId, 
    IF(c.category=0, c.company, CONCAT(c.lastname, IF(c.firstname != '', CONCAT(' ', c.firstname), ''))) custName,
    c.ctime,
    c.category,
    cc.tag compType,
    g.shortTag gender,
    c.location,
    JSON_VALUE(c.location, "$[2]") street,
    c.city,
    c.postcode
  FROM customer c
    LEFT JOIN companyClass cc ON c.type = cc.id
    LEFT JOIN gender g ON c.gender = g.id
    HAVING IF(_words IS NULL, 1, `custName` REGEXP _words)
  ORDER BY 
    CASE WHEN LCASE(_sort_by) = 'name' and LCASE(_order) = 'asc' THEN custName END ASC,
    CASE WHEN LCASE(_sort_by) = 'name' and LCASE(_order) = 'desc' THEN custName END DESC,
    CASE WHEN LCASE(_sort_by) = 'location' and LCASE(_order) = 'asc' THEN street END ASC,
    CASE WHEN LCASE(_sort_by) = 'location' and LCASE(_order) = 'desc' THEN street END DESC,
    CASE WHEN LCASE(_sort_by) = 'ctime' and LCASE(_order) = 'asc' THEN ctime END ASC,
    CASE WHEN LCASE(_sort_by) = 'ctime' and LCASE(_order) = 'desc' THEN ctime END DESC
  LIMIT _offset ,_range;
END$

DELIMITER ;
