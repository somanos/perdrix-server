
DELIMITER $

DROP PROCEDURE IF EXISTS `seo_search`$
CREATE PROCEDURE `seo_search`(
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

  DROP TABLE IF EXISTS _results;
  CREATE TEMPORARY TABLE _results(
    `ikey` text DEFAULT NULL,
    `ref_id` varchar(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
    `word` TEXT NOT NULL,
    `relevance` double DEFAULT 0
  );

  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'lastname') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), "") INTO _words;

  CALL yp.pageToLimits(_page, _offset, _range);
  SELECT REGEXP_REPLACE(_words, '^ +| +$', '') INTO _key;
  SELECT REGEXP_REPLACE(_key, ' +', ',') INTO _key;
  
  INSERT INTO _results SELECT 
    _key ikey, ref_id, word, MATCH(word) AGAINST(_key) relevance 
      FROM seo WHERE MATCH(word) AGAINST (_key IN BOOLEAN mode) 
      ORDER BY relevance DESC LIMIT _offset, _range;

  DROP TABLE IF EXISTS _view;
  CREATE TEMPORARY TABLE _view(
    itemId INTEGER UNSIGNED,
    word TEXT,
    relevance DOUBLE DEFAULT 0,
    ctype VARCHAR(16),
    content JSON,
    ctime INT(11) UNSIGNED,
    PRIMARY KEY (itemId, ctype)
  );

  DROP TABLE IF EXISTS _types;
  CREATE TEMPORARY TABLE _types(
    companyclass VARCHAR(32)
  );

  IF _tables IS NULL OR json_array_contains(_tables, "site") THEN
    REPLACE INTO _view SELECT 
      c.id, 
      r.word,
      r.relevance,
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
      c.ctime
      FROM `site` s 
        INNER JOIN seo_object o USING(id) 
        INNER JOIN customer c ON c.id=s.custId AND s.id=o.id
        INNER JOIN _results r USING(ref_id) 
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE o.table = 'site';
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "customer") THEN
    REPLACE INTO _view SELECT 
      c.id, 
      r.word,
      r.relevance,
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
        INNER JOIN seo_object o USING(id) 
        INNER JOIN _results r USING(ref_id) 
        LEFT JOIN companyClass cc ON c.type = cc.id
        LEFT JOIN gender g ON g.id=c.gender
        WHERE o.table = 'customer';
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "poc") THEN
    REPLACE INTO _view SELECT 
      c.id, 
      r.word,
      r.relevance,
      'poc',
      JSON_OBJECT(
        'custId', c.id,
        'custName', IF(c.category=0, c.company, CONCAT(c.lastname, IF(c.firstname != '', CONCAT(' ', c.firstname), ''))),
        'companyclass', cc.tag,
        'city', c.city,
        'location', c.location,
        'geometry', c.geometry,
        'category', c.category,
        'pocGender', g.shortTag,
        'gender', gg.shortTag,
        'siteId', p.siteId,
        'pocName', CONCAT(p.lastname, IF(p.firstname != '', CONCAT(' ', p.firstname), '')),
        'email', p.email,
        'phones', p.phones
      ) content,
      c.ctime
      FROM poc p
        INNER JOIN seo_object o USING(id) 
        INNER JOIN customer c ON c.id=p.custId AND p.id=o.id
        INNER JOIN _results r USING(ref_id)
        LEFT JOIN gender g ON g.id=p.gender
        LEFT JOIN gender gg ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE o.table = 'poc';
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "work") THEN
    REPLACE INTO _view SELECT 
      w.id, 
      r.word,
      r.relevance,
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
        'docId', q.docId,
        'ctime', q.ctime,
        'statut', q.status
      ) content,
      q.ctime
      FROM work w
        INNER JOIN seo_object o USING(id) 
        INNER JOIN _results r USING(ref_id)
        INNER JOIN quotation q ON w.id=q.workId AND w.custId=q.custId
        INNER JOIN workType wt ON w.category=wt.id
        INNER JOIN customer c ON c.id=w.custId AND w.custId=q.custId
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE o.table = 'work';
  END IF;

  SELECT *, ctype `type` FROM _view ORDER BY relevance LIMIT _offset ,_range;
END$

DELIMITER ;
