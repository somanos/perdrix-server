
DELIMITER $

DROP FUNCTION IF EXISTS `bill_chrono`$
CREATE FUNCTION `bill_chrono`(
)
RETURNS VARCHAR(120) DETERMINISTIC
BEGIN
  DECLARE _year INTEGER;
  DECLARE _month INTEGER;
  DECLARE _number INTEGER;
  DECLARE _start INTEGER DEFAULT 65;
  DECLARE _chrono VARCHAR(200);
  DECLARE _count INTEGER DEFAULT 0;

  SELECT DATE_FORMAT(now(), "%y") INTO _year;
  SELECT DATE_FORMAT(now(), "%m") INTO _month;
  IF _month >= 10 THEN
    SELECT _year + 1 INTO _year;
  END IF;
  SELECT REGEXP_REPLACE(chrono,'^[0-9]{2,2}\.', '')
    FROM bill WHERE chrono LIKE CONCAT(_year, '.', "%")
    ORDER BY ctime DESC LIMIT 1 INTO _number; 

  IF _number IS NULL THEN 
    SELECT 500 INTO _number;
  END IF;
  SELECT _number+1 INTO _number;
  SELECT IF(skip_number(_number), _number+1, _number) INTO _number;

  IF skip_number(_number) THEN
    SELECT _number+1 INTO _number;
  END IF;
  
  SELECT CONCAT(
      LPAD(_year, 2,'0'), '.', LPAD(_number, 4, '0')
    ) INTO _chrono;
  RETURN _chrono;
END$
 

DELIMITER ;
