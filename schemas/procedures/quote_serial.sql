
DELIMITER $


DROP FUNCTION IF EXISTS `quote_serial`$
CREATE FUNCTION `quote_serial`(
  _workId INTEGER
)
RETURNS VARCHAR(120) DETERMINISTIC
BEGIN
  DECLARE _year INTEGER;
  DECLARE _month INTEGER;
  DECLARE _serial INTEGER;
  DECLARE _version VARCHAR(2) DEFAULT 'A';

  SELECT `serial` FROM quote WHERE workId=_workId 
    ORDER BY ctime DESC LIMIT 1
    INTO _serial;
    
  SELECT DATE_FORMAT(now(), "%Y") INTO _year;
  SELECT DATE_FORMAT(now(), "%m") INTO _month;
  IF _month >= 10 THEN
    SELECT _year + 1 INTO _year;
  END IF;
  IF _serial IS NULL THEN 
    SELECT MAX(`serial`) FROM quote WHERE fiscalYear = _year INTO _serial;
    IF _serial IS NULL THEN 
      SELECT 100 INTO _serial;
    END IF;
    SELECT _serial + 1 INTO _serial;
  END IF;

  RETURN _serial;
END$


DELIMITER ;
