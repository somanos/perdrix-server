
DELIMITER $

DROP FUNCTION IF EXISTS `normalize_name`$
CREATE FUNCTION `normalize_name`(
  _category INTEGER,
  _company VARCHAR(255), 
  _lastname VARCHAR(255),  
  _firstname VARCHAR(255)
)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
  DECLARE _normalized VARCHAR(255);

  IF _category=0 THEN
    SET _normalized = UPPER(_company);
  ELSE
    SET _normalized = CONCAT(
      UPPER(_lastname), IF(_firstname != '', CONCAT(' ', _firstname), ''), ''
    );
  END IF;

  RETURN _normalized;
END$

DELIMITER ;
