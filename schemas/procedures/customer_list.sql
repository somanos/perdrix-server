
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
  DECLARE _addressId INTEGER;
  DECLARE _words TEXT;

  
  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), '.+') INTO _words;
  SELECT JSON_VALUE(_args, "$.addressId") INTO _addressId;
  CALL yp.pageToLimits(_page, _offset, _range);  

  SELECT 
    c.id custId, 
    a.id addressId,
    normalize_name(c.category, c.company, c.lastname, c.firstname) custName,
    _page `page`,
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
    LEFT JOIN gender g ON c.gender = g.id HAVING 
    IF(_words IS NULL, 1, `custName` REGEXP _words) AND
    IF(_addressId IS NULL, 1, addressId=_addressId)

  ORDER BY 
    CASE WHEN LCASE(_sort_by) = 'name' and LCASE(_order) = 'asc' THEN custName END ASC,
    CASE WHEN LCASE(_sort_by) = 'name' and LCASE(_order) = 'desc' THEN custName END DESC,
    CASE WHEN LCASE(_sort_by) = 'location' and LCASE(_order) = 'asc' THEN street END ASC,
    CASE WHEN LCASE(_sort_by) = 'location' and LCASE(_order) = 'desc' THEN street END DESC,
    CASE WHEN LCASE(_sort_by) = 'ctime' and LCASE(_order) = 'asc' THEN c.ctime END ASC,
    CASE WHEN LCASE(_sort_by) = 'ctime' and LCASE(_order) = 'desc' THEN c.ctime END DESC
  LIMIT _offset ,_range;
END$

DELIMITER ;
