
DELIMITER $

DROP FUNCTION IF EXISTS `quote_get_chrono`$
CREATE FUNCTION `quote_get_chrono`(
)
RETURNS VARCHAR(120) DETERMINISTIC
BEGIN
  DECLARE _fiscal_year INTEGER;
  DECLARE _number INTEGER;

  SELECT DATE_FORMAT(now(), "%y") INTO _fiscal_year;
  SELECT REGEXP_REPLACE(chrono,'^[0-9]{2,2}\.|[A-Z]{1,1}$', '')
    FROM quotation WHERE chrono LIKE CONCAT(_fiscal_year, '.', "%")
    ORDER BY ctime DESC LIMIT 1 INTO _number; 
  IF _number IS NULL THEN 
    SELECT 0 INTO _number;
  END IF;
  SELECT _number+1 INTO _number;
  SELECT IF(skip_number(_number), _number+1, _number) INTO _number;
  RETURN CONCAT(_fiscal_year, '.', LPAD(_number, 3, '0'), 'A');
END$
 


DELIMITER ;
