
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
    -- CONCAT('[', GROUP_CONCAT(JSON_OBJECT(
    --   'custId', w.custId,
    --   'chrono', q.chrono,
    --   'description', q.description,
    --   'ht', q.ht,
    --   'tva', q.tva,
    --   'ttc', q.ttc,
    --   'discount', q.discount,
    --   'nid', q.docId,
    --   'hub_id', _hub_id,
    --   'filepath', filepath(q.docId),
    --   'ctime', q.ctime,
    --   'status', q.status
    -- )), ']') `quote`,
    -- CONCAT('[', GROUP_CONCAT(JSON_OBJECT(
    --   'custId', w.custId,
    --   'chrono', b.chrono,
    --   'description', q.description,
    --   'ht', b.ht,
    --   'tva', b.tva,
    --   'ttc', b.ttc,
    --   'nid', b.docId,
    --   'hub_id', _hub_id,
    --   'filepath', filepath(b.docId),
    --   'ctime', b.ctime,
    --   'status', b.status,
    --   'category', b.category
    -- )), ']') `bill`,
    -- CONCAT('[', GROUP_CONCAT(JSON_OBJECT(
    --   'custId', n.custId,
    --   'siteId', n.siteId,
    --   'workId', n.workId,
    --   'description', n.description,
    --   'docId', n.docId,
    --   'nid', b.docId,
    --   'hub_id', _hub_id,
    --   'ctime', n.ctime,
    --   'noteId', n.id,
    --   'id', n.id
    -- )), ']') `note`,
    -- JSON_OBJECT(
    --   'custId', s.custId,
    --   'countrycode', s.countrycode,
    --   'location', s.location,
    --   'postcode', s.postcode,
    --   'city', s.city,
    --   'geometry', s.geometry,
    --   'ctime', s.ctime,
    --   'statut', s.statut,
    --   'siteId', s.id,
    --   'id', s.id
    -- ) `site`
  FROM work w
    LEFT JOIN `workType` t ON t.id=w.category
    WHERE w.id=_workId;
END$

DELIMITER ;
