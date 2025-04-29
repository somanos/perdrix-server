
DELIMITER $

DROP PROCEDURE IF EXISTS `work_get`$
CREATE PROCEDURE `work_get`(
  IN _workId INTEGER
)
BEGIN
  SELECT 
    w.*,
    w.id workId,
    t.tag `type`,
    t.tag `workType`
    FROM work w
      LEFT JOIN `workType` t ON t.id=w.category
      WHERE w.id = _workId;
END$

DELIMITER ;
