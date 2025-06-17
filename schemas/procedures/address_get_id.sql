
DELIMITER $

DROP FUNCTION IF EXISTS `adress_get_id`$
DROP FUNCTION IF EXISTS `address_get_id`$
CREATE FUNCTION `address_get_id`(
  _location JSON,
  _postcode  varchar(200),
  _countrycode INTEGER
)
RETURNS INTEGER DETERMINISTIC
BEGIN
  DECLARE _id INTEGER;
  SELECT id FROM address 
    WHERE postcode=_postcode AND location=_location AND countrycode=_countrycode INTO _id;
  RETURN _id;
END$
 
DELIMITER ;
