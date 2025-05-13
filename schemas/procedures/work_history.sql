
DELIMITER $

DROP PROCEDURE IF EXISTS `work_history`$
CREATE PROCEDURE `work_history`(
  IN _workId INTEGER
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _hub_id VARCHAR(20);

  DECLARE _status JSON ;


  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;

  SELECT
    w.*,
    t.tag `type`,
    t.tag `workType`
  FROM work w
    LEFT JOIN `workType` t ON t.id=w.category
    WHERE w.id=_workId;
END$

DELIMITER ;
