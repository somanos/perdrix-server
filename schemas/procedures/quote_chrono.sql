
DELIMITER $

DROP FUNCTION IF EXISTS `quote_chrono`$
CREATE FUNCTION `quote_chrono`(
)
RETURNS VARCHAR(120) DETERMINISTIC
BEGIN
  DECLARE _fiscal_year INTEGER;
  DECLARE _number INTEGER;
  DECLARE _start INTEGER DEFAULT 65;
  DECLARE _chrono VARCHAR(200);
  DECLARE _count INTEGER DEFAULT 0;

  SELECT DATE_FORMAT(now(), "%y") INTO _fiscal_year;
  SELECT REGEXP_REPLACE(chrono,'^[0-9]{2,2}\.|[A-Z]{1,1}$', '')
    FROM quotation WHERE chrono LIKE CONCAT(_fiscal_year, '.', "%")
    ORDER BY ctime DESC LIMIT 1 INTO _number; 
  IF _number IS NULL THEN 
    SELECT 0 INTO _number;
  END IF;
  SELECT _number+1 INTO _number;
  SELECT IF(skip_number(_number), _number+1, _number) INTO _number;
  SELECT ASCII('A') INTO _start;
  WHILE _start <= 91 DO 
    SELECT CONCAT(_fiscal_year, '.', LPAD(_number, 3, '0'), CHAR(_start)) INTO _chrono;
    SELECT count(*) FROM quotation WHERE chrono=_chrono INTO _count;
    IF NOT _count THEN 
      RETURN _chrono;
    END IF;
    SELECT _start + 1 INTO _start;
  END WHILE;
  RETURN _chrono;
END$
 

DELIMITER ;
