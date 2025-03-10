
DELIMITER $
DROP FUNCTION IF EXISTS `json_array_contains`$
CREATE FUNCTION `json_array_contains`(
  _data JSON,
  _arg VARCHAR(160)
)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
  DECLARE _res BOOLEAN;
  DECLARE _list JSON;
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;
  DECLARE _db VARCHAR(160);
  DECLARE _item VARCHAR(160);
  DECLARE _id VARCHAR(160);

  IF JSON_TYPE(_data) != 'ARRAY' THEN 
    SELECT JSON_ARRAY(_data) INTO _list;
  ELSE
    SELECT _data INTO _list;
  END IF;

  IF _list IS NULL OR JSON_LENGTH(_list)=0 THEN
    RETURN 0;
  END IF;

  WHILE _i < JSON_LENGTH(_list) DO 
    SELECT JSON_VALUE(_list, CONCAT("$[", _i, "]")) INTO _item;
    SET @g=CONCAT("$[", _i, "]", _arg, "  ", _item);
    IF _item = _arg THEN
      RETURN 1;
    END IF;
    SELECT _i + 1 INTO _i;
  END WHILE;
  RETURN 0;
END$

DELIMITER ;
