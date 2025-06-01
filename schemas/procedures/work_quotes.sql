
DELIMITER $

DROP PROCEDURE IF EXISTS `work_quotes`$
CREATE PROCEDURE `work_quotes`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _hub_id VARCHAR(20);
  DECLARE _uid VARCHAR(20);
  DECLARE _home_id VARCHAR(20);

  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _workId INTEGER ;

  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.uid"), "ffffffffffffffff") INTO _uid;
  SET @uid=_uid;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  SELECT JSON_VALUE(_args, "$.workId") INTO _workId;
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT id, home_id FROM yp.entity WHERE db_name=database() INTO _hub_id, _home_id;

  SELECT
    q.*,
    m.id nid,
    m.file_path filepath,
    IF(m.extension ='' OR m.extension IS NULL, 
      m.user_filename, CONCAT(m.user_filename, '.', m.extension)
    ) `filename`,
    user_permission(_uid, m.id) privilege,
    _home_id home_id,
    _hub_id hub_id
  FROM quote q
    LEFT JOIN media m ON m.file_path=concat('/devis/',fiscalYear,'/odt/dev', chrono, '.odt')
    WHERE q.workId=_workId
    ORDER BY q.ctime DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
