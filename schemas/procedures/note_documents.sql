
DELIMITER $

DROP PROCEDURE IF EXISTS `note_documents`$
CREATE PROCEDURE `note_documents`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _hub_id VARCHAR(20);

  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _noteId INTEGER ;

  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'name') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  SELECT JSON_VALUE(_args, "$.noteId") INTO _noteId;
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;

  SELECT
    d.*,
    m.id nid,
    m.file_path filepath,
    _hub_id hub_id
  FROM document d
    INNER JOIN note n ON n.id = d.noteId
    INNER JOIN media m ON m.id = d.id
    WHERE d.noteId=_noteId
    ORDER BY d.ctime DESC
    LIMIT _offset ,_range;
END$

DELIMITER ;
