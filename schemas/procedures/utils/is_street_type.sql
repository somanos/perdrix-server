
DELIMITER $

DROP FUNCTION IF EXISTS `is_street_type`$
CREATE FUNCTION `is_street_type`(
  _str VARCHAR(512)
)
RETURNS BOOLEAN DETERMINISTIC
BEGIN
  DECLARE _res BOOLEAN;
  DECLARE _count INTEGER DEFAULT 0;

  SELECT count(*) FROM streetType WHERE longTag regexp _str OR shortTag regexp _str INTO _count;
  RETURN _count>0;
END$
 
DELIMITER ;
