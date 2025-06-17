
DELIMITER $

DROP PROCEDURE IF EXISTS `address_list`$
CREATE PROCEDURE `address_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _housenumber TEXT;
  DECLARE _streettype TEXT;
  DECLARE _street TEXT;
  DECLARE _city TEXT;
  DECLARE _postcode TEXT;

  
  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;
  SELECT JSON_VALUE(_args, "$.street") INTO _street;
  SELECT JSON_VALUE(_args, "$.housenumber") INTO _housenumber;
  SELECT JSON_VALUE(_args, "$.streettype") INTO _streettype;
  SELECT JSON_VALUE(_args, "$.city") INTO _city;
  SELECT JSON_VALUE(_args, "$.postcode") INTO _postcode;
  CALL yp.pageToLimits(_page, _offset, _range);  

  SELECT 
    a.id, 
    a.id addressId, 
    _page `page`,
    a.ctime,
    a.location,
    a.geometry,
    a.streetname,
    a.city,
    a.postcode
  FROM address a WHERE 
    IF(_housenumber IS NULL, 1, a.housenumber REGEXP _housenumber) AND
    IF(_streettype IS NULL, 1, a.streettype REGEXP _streettype) AND
    IF(_street IS NULL, 1, a.streetname REGEXP _street) AND
    IF(_city IS NULL, 1, a.city  REGEXP _city) AND
    IF(_postcode IS NULL, 1, a.postcode=_postcode) 

  ORDER BY 
    CASE WHEN LCASE(_sort_by) = 'city' and LCASE(_order) = 'asc' THEN city END ASC,
    CASE WHEN LCASE(_sort_by) = 'city' and LCASE(_order) = 'desc' THEN city END DESC,
    CASE WHEN LCASE(_sort_by) = 'street' and LCASE(_order) = 'asc' THEN streetname END ASC,
    CASE WHEN LCASE(_sort_by) = 'street' and LCASE(_order) = 'desc' THEN streetname END DESC,
    CASE WHEN LCASE(_sort_by) = 'ctime' and LCASE(_order) = 'asc' THEN ctime END ASC,
    CASE WHEN LCASE(_sort_by) = 'ctime' and LCASE(_order) = 'desc' THEN ctime END DESC
  LIMIT _offset ,_range;
END$

DELIMITER ;
