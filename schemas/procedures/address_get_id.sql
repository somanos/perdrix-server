
DELIMITER $

DROP FUNCTION IF EXISTS `address_get_id`$
CREATE FUNCTION `address_get_id`(
  _location JSON,
  _postcode  varchar(200),
  _countrycode INTEGER
)
RETURNS INTEGER DETERMINISTIC
BEGIN
  DECLARE _id INTEGER;
  SELECT id FROM address WHERE 
    postcode=_postcode AND 
    countrycode=_countrycode AND 
    JSON_VALUE(_location, "$[0]")=housenumber AND
    JSON_VALUE(_location, "$[1]")=streettype AND
    JSON_VALUE(_location, "$[2]")=streetname AND
    JSON_VALUE(_location, CONCAT("$[3]"))=additional INTO _id;
  RETURN _id;
END$
 
DELIMITER ;
