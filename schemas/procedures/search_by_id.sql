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
  DECLARE _hub_id VARCHAR(20);
  DECLARE _words TEXT;
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'lastname') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), "") INTO _words;

  CALL yp.pageToLimits(_page, _offset, _range);
  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;
  DROP TABLE IF EXISTS _view;
  CREATE TEMPORARY TABLE _view(
    itemId INTEGER UNSIGNED,
    `type` VARCHAR(16),
    content JSON,
    reference JSON,
    PRIMARY KEY (itemId, `type`)
  );

  IF _tables IS NULL OR json_array_contains(_tables, "quote") THEN
    REPLACE INTO _view SELECT 
      q.id,
      'quote',
      JSON_OBJECT(
        'id', q.id,
        'quoteId', q.id,
        'custId', q.custId,
        'siteId', q.siteId,
        'workId', q.workId,
        'chrono', q.chrono,
        'fiscalYear', q.fiscalYear,
        'description', q.description,
        'ht', q.ht,
        'tva', q.tva,
        'ttc', q.ttc,
        'discount', q.discount,
        'filepath', m.file_path,
        'nid', m.id,
        'hub_id', _hub_id,
        'ctime', q.ctime
      ) content,
      JSON_ARRAY(
        JSON_OBJECT(
          'id', c.id,
          'custId', c.id,
          'gender', g.shortTag,
          'companyclass', cc.tag,
          'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
          'location', c.location,
          'site', c.location,
          'geometry', c.geometry,
          'city', c.city,
          'postcode', c.postcode
        ),
        JSON_OBJECT(
          'id', s.id,
          'siteId', s.id,
          'location', s.location,
          'geometry', s.geometry,
          'city', s.city,
          'postcode', s.postcode
        ),
        JSON_OBJECT(
          'id', w.id,
          'workId', w.id,
          'description', w.description,
          'ctime', w.ctime ,
          'type', wt.tag
        )
      )
      FROM `quote` q
        INNER JOIN customer c ON c.id=q.custId
        INNER JOIN `site` s ON s.id=q.siteId
        INNER JOIN `work` w ON w.id=q.workId
        INNER JOIN `workType` wt ON wt.id=w.category
        LEFT JOIN media m ON m.file_path=concat('/devis/',fiscalYear,'/odt/dev', chrono, '.odt')
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE c.id > 0 AND q.chrono REGEXP _words;
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "bill") THEN
    REPLACE INTO _view SELECT 
      b.id, 
      'bill',
      JSON_OBJECT(
        'id', b.id,
        'billId', b.id,
        'custId', b.custId,
        'siteId', s.id,
        'workId', b.workId,
        'chrono', b.chrono,
        'fiscalYear', b.fiscalYear,
        'description', b.description,
        'ht', b.ht,
        'tva', b.tva,
        'ttc', b.ttc,
        'filepath', m.file_path,
        'nid', m.id,
        'hub_id', _hub_id,
        'ctime', b.ctime
      ) content,
      JSON_ARRAY(
        JSON_OBJECT(
          'id', c.id,
          'custId', c.id,
          'gender', g.shortTag,
          'companyclass', cc.tag,
          'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
          'location', c.location,
          'site', c.location,
          'geometry', c.geometry,
          'city', c.city,
          'postcode', c.postcode
        ),
        JSON_OBJECT(
          'id', s.id,
          'siteId', s.id,
          'location', s.location,
          'geometry', s.geometry,
          'city', s.city,
          'postcode', s.postcode
        ),
        JSON_OBJECT(
          'id', w.id,
          'workId', w.id,
          'description', w.description,
          'ctime', w.ctime ,
          'type', wt.tag
        )
      )
      FROM `bill` b
        INNER JOIN customer c ON c.id=b.custId
        INNER JOIN `site` s ON s.id=b.siteId
        INNER JOIN `work` w ON w.id=b.workId
        LEFT JOIN workType wt ON w.category=wt.id
        LEFT JOIN media m ON m.file_path=concat('/devis/',fiscalYear,'/odt/dev', chrono, '.odt')
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE c.id > 0 AND b.chrono REGEXP _words;
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "site") THEN
    REPLACE INTO _view SELECT 
      s.id, 
      'site',
      JSON_OBJECT(
        'id', s.id,
        'custId', c.id,
        'siteId', s.id,
        'location', s.location,
        'geometry', s.geometry,
        'city', s.city,
        'postcode', s.postcode,
        'ctime', s.ctime
      ),
      JSON_ARRAY(
        JSON_OBJECT(
          'custId', c.id,
          'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
          'companyclass', cc.tag,
          'gender', g.shortTag,
          'location', c.location,
          'city', c.city,
          'geometry', c.geometry,
          'postcode', c.postcode
        )
      )
      FROM `site` s 
        INNER JOIN customer c ON c.id=s.custId
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE c.id > 0 AND s.id REGEXP _words;
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "customer") THEN
    REPLACE INTO _view SELECT 
      c.id, 
      'customer',
      JSON_OBJECT(
        'id', c.id,
        'custId', c.id,
        'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
        'companyclass', cc.tag,
        'gender', g.shortTag,
        'location', c.location,
        'city', c.city,
        'geometry', c.geometry,
        'postcode', c.postcode
      ),
      JSON_ARRAY()
      FROM customer c 
        LEFT JOIN companyClass cc ON c.type = cc.id
        LEFT JOIN gender g ON g.id=c.gender
        WHERE c.id > 0 AND c.id REGEXP _words;
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "work") THEN
    REPLACE INTO _view SELECT 
      w.id, 
      'work',
      JSON_OBJECT(
        'id', w.id,
        'type',  wt.tag,
        'siteId', s.id,
        'workId', w.id,
        'location', s.location,
        'description', w.description,
        'city', s.city,
        'postcode', s.postcode,
        'ctime', w.ctime
      ),
      JSON_ARRAY(
        JSON_OBJECT(
          'id', c.id,
          'custId', c.id,
          'gender', g.shortTag,
          'companyclass', cc.tag,
          'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
          'location', c.location,
          'site', c.location,
          'geometry', c.geometry,
          'city', c.city,
          'postcode', c.postcode
        ),
        JSON_OBJECT(
          'id', s.id,
          'siteId', s.id,
          'location', s.location,
          'geometry', s.geometry,
          'city', s.city,
          'postcode', s.postcode
        )
      )
      FROM work w
        INNER JOIN workType wt ON w.category=wt.id
        INNER JOIN customer c ON c.id=w.custId AND w.custId=q.custId
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE c.id > 0 AND w.id REGEXP _words;
  END IF;

  SELECT * FROM _view LIMIT _offset ,_range;
END$

DELIMITER ;
