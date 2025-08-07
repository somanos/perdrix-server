
DELIMITER $

DROP FUNCTION IF EXISTS `address_get_id`$
CREATE FUNCTION `address_get_id`(
  _housenumber VARCHAR(200), 
  _streettype VARCHAR(200),
  _streetname VARCHAR(200),
  _additional VARCHAR(200),
  _postcode VARCHAR(200),
  _countrycode INTEGER
)
RETURNS INTEGER DETERMINISTIC
BEGIN
  DECLARE _id INTEGER;
  SELECT id FROM address WHERE 
    postcode    = _postcode AND 
    countrycode = _countrycode AND 
    housenumber = _housenumber AND
    streettype  = _streettype AND
    streetname  = _streetname AND
    additional  = _additional 
    LIMIT 1 INTO _id;
  RETURN _id;
END$
 
DELIMITER ;
