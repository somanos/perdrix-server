
DELIMITER $


DROP FUNCTION IF EXISTS `bill_serial`$
CREATE FUNCTION `bill_serial`(
)
RETURNS VARCHAR(120) DETERMINISTIC
BEGIN
  DECLARE _year INTEGER;
  DECLARE _month INTEGER;
  DECLARE _serial INTEGER;
    
  SELECT DATE_FORMAT(now(), "%Y") INTO _year;
  SELECT DATE_FORMAT(now(), "%m") INTO _month;
  IF _month >= 10 THEN
    SELECT _year + 1 INTO _year;
  END IF;
  SELECT MAX(`serial`) FROM bill WHERE fiscalYear = _year INTO _serial;
  IF _serial IS NULL THEN 
    SELECT 500 INTO _serial;
  END IF;
  SELECT _serial + 1 INTO _serial;

  RETURN _serial;
END$


DELIMITER ;
