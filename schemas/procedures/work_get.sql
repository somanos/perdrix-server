
DELIMITER $

DROP PROCEDURE IF EXISTS `work_get`$
CREATE PROCEDURE `work_get`(
  IN _id INTEGER
)
BEGIN
  SELECT 
    *,
    id workId
    FROM work
      WHERE id = _id;
END$

DELIMITER ;
