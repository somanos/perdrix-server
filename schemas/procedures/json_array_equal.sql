
DELIMITER $
DROP FUNCTION IF EXISTS `json_array_equal`$
CREATE FUNCTION `json_array_equal`(
  _loc1 JSON,
  _loc2 JSON
)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
  DECLARE _length TINYINT(6) unsigned DEFAULT 0;
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;

  IF _loc1 IS NULL OR _loc2 IS NULL THEN 
    RETURN 0;
  END IF;

  IF JSON_TYPE(_loc1) != JSON_TYPE(_loc1) THEN 
    RETURN 0;
  END IF;

  IF JSON_TYPE(_loc1) != 'ARRAY' THEN 
    RETURN 0;
  END IF;

  IF JSON_LENGTH(_loc1) > JSON_LENGTH(_loc2) THEN 
    SELECT JSON_LENGTH(_loc1) INTO _length;
  ELSE
    SELECT JSON_LENGTH(_loc2) INTO _length;
  END IF;

  WHILE _i < _length DO
    SELECT NULL, NULL INTO  @_val1, @_val2;
    SELECT JSON_VALUE(_loc1, CONCAT("$[", _i, "]")) INTO @_val1;
    SELECT JSON_VALUE(_loc2, CONCAT("$[", _i, "]")) INTO @_val2;
    IF @_val1 IS NOT NULL AND @_val2 IS NOT NULL THEN
      IF @_val1 != @_val2 THEN
        RETURN 0;
      END IF;
    END IF;
    SELECT _i + 1 INTO _i;
  END WHILE;
  RETURN 1;
END$

DELIMITER ;
