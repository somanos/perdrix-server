
DELIMITER $

DROP PROCEDURE IF EXISTS `address_modify`$
CREATE PROCEDURE `address_modify`(
  IN _args JSON
)
BEGIN
  DECLARE _housenumber VARCHAR(10);
  DECLARE _streettype VARCHAR(512);
  DECLARE _streetcode INTEGER;
  DECLARE _streetname VARCHAR(512);
  DECLARE _additional VARCHAR(512);
  DECLARE _id INTEGER;
  DECLARE _ccode INTEGER;
  DECLARE _postcode INTEGER;
  DECLARE _citycode INTEGER;
  DECLARE _city VARCHAR(512);
  DECLARE _countrycode VARCHAR(512);
  DECLARE _reference JSON;
  DECLARE _geometry JSON;

  SELECT JSON_VALUE(_args, "$.id") INTO _id;
  SELECT JSON_VALUE(_args, "$.housenumber") INTO _housenumber;
  SELECT JSON_VALUE(_args, "$.streettype") INTO _streettype;
  SELECT JSON_VALUE(_args, "$.streetname") INTO _streetname;
  SELECT JSON_VALUE(_args, "$.additional") INTO _additional;
  SELECT JSON_VALUE(_args, "$.postcode") INTO _postcode;
  SELECT JSON_VALUE(_args, "$.city") INTO _city;
  SELECT JSON_VALUE(_args, "$.countrycode") INTO  _countrycode;

  SELECT id FROM country WHERE code=_countrycode INTO _ccode;

  IF _housenumber IS NOT NULL THEN 
    UPDATE address SET housenumber=_housenumber WHERE id=_id;
  END IF;

  IF _streettype IS NOT NULL THEN 
    UPDATE address SET streettype=_streettype WHERE id=_id;
  END IF;

  IF _streetname IS NOT NULL THEN 
    UPDATE address SET streetname=_streetname WHERE id=_id;
  END IF;

  IF _additional IS NOT NULL THEN 
    UPDATE address SET additional=_additional WHERE id=_id;
  END IF;

  IF _postcode IS NOT NULL THEN 
    UPDATE address SET postcode=_postcode WHERE id=_id;
  END IF;

  IF _city IS NOT NULL THEN 
    UPDATE address SET city=_city WHERE id=_id;
  END IF;

  IF _ccode IS NOT NULL THEN 
    UPDATE address SET countrycode=_ccode WHERE id=_id;
  END IF;
  
END$
 
DELIMITER ;
