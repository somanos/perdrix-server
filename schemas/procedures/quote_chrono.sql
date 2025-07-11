
DELIMITER $

DROP FUNCTION IF EXISTS `quote_chrono`$
CREATE FUNCTION `quote_chrono`(
  _workId INTEGER
)
RETURNS VARCHAR(120) DETERMINISTIC
BEGIN
  DECLARE _year INTEGER;
    DECLARE _month INTEGER;

  DECLARE _number INTEGER;
  DECLARE _start INTEGER DEFAULT 65;
  DECLARE _chrono VARCHAR(200);
  DECLARE _count INTEGER DEFAULT 0;

  SELECT chrono FROM quotation WHERE workId=_workId 
    ORDER BY ctime DESC LIMIT 1
    INTO _chrono;
    
  SELECT DATE_FORMAT(now(), "%y") INTO _year;
  SELECT DATE_FORMAT(now(), "%m") INTO _month;
  IF _month >= 10 THEN
    SELECT _year + 1 INTO _year;
  END IF;
  IF _chrono IS NULL THEN 
    SELECT REGEXP_REPLACE(chrono,'^[0-9]{2,2}\.|[A-Z]{1,1}$', '')
      FROM quotation WHERE chrono LIKE CONCAT(_year, '.', "%")
      ORDER BY ctime DESC LIMIT 1 INTO _number; 
    IF _number IS NULL THEN 
      SELECT 100 INTO _number;
    END IF;
    SELECT _number+1 INTO _number;
    SELECT IF(skip_number(_number), _number+1, _number) INTO _number;
  ELSE
    SELECT REGEXP_REPLACE(_chrono,'^[0-9]{2,2}\.|[A-Z]{1,1}$', '') INTO _number;
  END IF;

  IF skip_number(_number) THEN
    SELECT _number+1 INTO _number;
  END IF;

  SELECT ASCII('A') INTO _start;

  WHILE _start <= 91 DO 
    SELECT CONCAT(
      LPAD(_year, 2,'0'), '.', LPAD(_number, 3, '0'), CHAR(_start)
    ) INTO _chrono;
    SELECT count(*) FROM quotation WHERE chrono=_chrono INTO _count;
    SELECT _count, _chrono INTO @_count, @_chrono;
    IF NOT _count THEN 
      RETURN _chrono;
    END IF;
    SELECT _start + 1 INTO _start;
  END WHILE;
  RETURN _chrono;
END$


DELIMITER ;
