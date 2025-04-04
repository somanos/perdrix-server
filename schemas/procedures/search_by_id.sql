
DELIMITER $

DROP PROCEDURE IF EXISTS `search_by_id`$
CREATE PROCEDURE `search_by_id`(
  IN _args JSON,
  IN _tables JSON
)
BEGIN
  DECLARE _key TEXT;
  DECLARE _offset INTEGER UNSIGNED;
  DECLARE _range INTEGER UNSIGNED;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'lastname';
  DECLARE _words TEXT;
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'lastname') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), "") INTO _words;

  CALL yp.pageToLimits(_page, _offset, _range);
  
  DROP TABLE IF EXISTS _view;
  CREATE TEMPORARY TABLE _view(
    itemId INTEGER UNSIGNED,
    ctype VARCHAR(16),
    content JSON,
    ctime INT(11) UNSIGNED,
    PRIMARY KEY (itemId, ctype)
  );

  IF _tables IS NULL OR json_array_contains(_tables, "site") THEN
    REPLACE INTO _view SELECT 
      s.id, 
      'site',
      JSON_OBJECT(
        'custId', c.id,
        'gender', g.shortTag,
        'companyclass', cc.tag,
        'custName', IF(c.category=0, c.company, CONCAT(c.lastname, IF(c.firstname != '', CONCAT(' ', c.firstname), ''))),
        'location', c.location,
        'site', s.location,
        'geometry', s.geometry,
        'city', s.city,
        'postcode', s.postcode
      ) content,
      s.ctime
      FROM `site` s 
        INNER JOIN customer c ON c.id=s.custId
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE s.id LIKE _words;
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "customer") THEN
    REPLACE INTO _view SELECT 
      c.id, 
      'customer',
      JSON_OBJECT(
        'custId', c.id,
        'custName', IF(c.category=0, c.company, CONCAT(c.lastname, IF(c.firstname != '', CONCAT(' ', c.firstname), ''))),
        'companyclass', cc.tag,
        'gender', g.shortTag,
        'location', c.location,
        'city', c.city,
        'geometry', c.geometry,
        'postcode', c.postcode
      ) content,
      c.ctime
      FROM customer c 
        LEFT JOIN companyClass cc ON c.type = cc.id
        LEFT JOIN gender g ON g.id=c.gender
        WHERE c.id LIKE _words;
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "work") THEN
    REPLACE INTO _view SELECT 
      w.id, 
      'work',
      JSON_OBJECT(
        'custName', IF(c.category=0, c.company, CONCAT(c.lastname, IF(c.firstname != '', CONCAT(' ', c.firstname), ''))),
        'type',  wt.tag,
        'companyclass', cc.tag,
        'gender', g.shortTag,
        'custId', c.id,
        'quoteId', q.id,
        'workId', w.id,
        'chrono', q.chrono,
        'location', c.location,
        'city', c.city,
        'description', w.description,
        'ht', q.ht,
        'taux_tva', q.tva,
        'val_tva', q.ttc-q.ht,
        'ttc', q.ttc,
        'discount', q.discount,
        'folderId', q.folderId,
        'ctime', q.ctime,
        'statut', q.status
      ) content,
      q.ctime
      FROM work w
        INNER JOIN quotation q ON w.id=q.workId AND w.custId=q.custId
        INNER JOIN workType wt ON w.category=wt.id
        INNER JOIN customer c ON c.id=w.custId AND w.custId=q.custId
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE w.id LIKE _words;
  END IF;

  SELECT *, ctype `type` FROM _view LIMIT _offset ,_range;
END$

DELIMITER ;
