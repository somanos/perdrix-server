
DELIMITER $

DROP FUNCTION IF EXISTS `get_poc_map_id`$
DROP FUNCTION IF EXISTS `get_poc_source_id`$
CREATE FUNCTION `get_poc_map_id`(
  _firstname VARCHAR(100),
  _lastname VARCHAR(100),
  _phones JSON
)
RETURNS INTEGER DETERMINISTIC
BEGIN
  DECLARE _res INTEGER;
  SELECT id FROM contact WHERE AND lastname=_lastname AND firstname=_firstname AND phones=_phones INTO _res;
  RETURN _res;
END$
 
DELIMITER ;
