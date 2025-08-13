
DELIMITER $

DROP FUNCTION IF EXISTS `address_get_id`$
CREATE FUNCTION `address_get_id`(
  _housenumber VARCHAR(200), 
  _streettype VARCHAR(200),
  _streetname VARCHAR(200),
  _additional VARCHAR(200),
  _postcode VARCHAR(200),
  _countrycode VARCHAR(200)
)
RETURNS INTEGER DETERMINISTIC
BEGIN
  DECLARE _id INTEGER;
  DECLARE _ccode INTEGER DEFAULT 36;
  SELECT IFNULL(id, 36) FROM country WHERE code=_countrycode INTO _ccode;
  SELECT id FROM address WHERE 
    postcode    = _postcode AND 
    countrycode = _ccode AND 
    housenumber = _housenumber AND
    streettype  = _streettype AND
    streetname  = _streetname AND
    additional  = _additional 
    LIMIT 1 INTO _id;
  RETURN _id;
END$
 
DELIMITER ;
