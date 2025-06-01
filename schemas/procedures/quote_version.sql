
DELIMITER $
DROP FUNCTION IF EXISTS `quote_version`$
CREATE FUNCTION `quote_version`(
  _workId INTEGER
)
RETURNS VARCHAR(120) DETERMINISTIC
BEGIN
  DECLARE _version VARCHAR(1) CHARACTER SET ascii COLLATE ascii_general_ci;

  SELECT `version` FROM quote WHERE workId=_workId 
    ORDER BY version DESC LIMIT 1
    INTO _version;
    
  IF _version IS NULL THEN 
    SELECT 'A' INTO _version;
  ELSE
    SELECT CHAR(ASCII(_version)+1) INTO _version;
  END IF;
  RETURN _version;
END$


DELIMITER ;
