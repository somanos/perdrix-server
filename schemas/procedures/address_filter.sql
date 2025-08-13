
DELIMITER $

DROP FUNCTION IF EXISTS `address_filter`$
CREATE FUNCTION `address_filter`(
  _filter JSON
)
RETURNS TEXT DETERMINISTIC
BEGIN
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;
  DECLARE _name TEXT;
  DECLARE _value TEXT;
  DECLARE _res TEXT DEFAULT "ORDER BY";
  DECLARE _tmp TEXT;

  IF JSON_TYPE(_filter) = 'ARRAY' AND JSON_LENGTH(_filter)>0 THEN 
    WHILE _i < JSON_LENGTH(_filter) DO 
      SELECT JSON_EXTRACT(_filter, CONCAT("$[", _i, "]")) INTO _tmp;
      SELECT JSON_VALUE(_tmp, "$.name") INTO _name;
      SELECT JSON_VALUE(_tmp, "$.value") INTO _value;
      SELECT CONCAT(_res, " ", _name, " ", _value) INTO _res;
      IF(_i < JSON_LENGTH(_filter) - 1) THEN
        SELECT CONCAT(_res, ",") INTO _res;
      END IF;
      SELECT _i + 1 INTO _i;
    END WHILE;
  ELSE
    SELECT CONCAT(_res, " ", "city asc, street asc, housenumber desc") INTO _res;
  END IF;
  RETURN _res;
END$
 
DELIMITER ;
