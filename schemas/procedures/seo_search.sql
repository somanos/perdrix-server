
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
    `type` VARCHAR(16),
    content JSON,
    reference JSON,
    PRIMARY KEY (itemId, `type`)
  );

  DROP TABLE IF EXISTS _types;
  CREATE TEMPORARY TABLE _types(
    companyclass VARCHAR(32)
  );

  IF _tables IS NULL OR json_array_contains(_tables, "site") THEN
    REPLACE INTO _view SELECT 
      s.id, 
      r.word,
      r.relevance,
      'site',
      JSON_OBJECT(
        'id', s.id,
        'addressId', a.id,
        'siteId', s.id,
        'location', a.location,
        'geometry', a.geometry,
        'city', a.city,
        'postcode', a.postcode
      ),
      JSON_ARRAY(
        JSON_OBJECT(
          'custId', c.id,
          'addressId', ca.id,
          'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
          'companyclass', cc.tag,
          'gender', g.shortTag,
          'location', a.location,
          'city', ca.city,
          'geometry', ca.geometry,
          'postcode', ca.postcode
        )
      )
      FROM `site` s 
        INNER JOIN seo_object o USING(id) 
        INNER JOIN customer c ON c.id=s.custId AND s.id=o.id
        INNER JOIN _results r USING(ref_id) 
        INNER JOIN `address` a ON s.addressId=a.id
        INNER JOIN `address` ca ON c.addressId=ca.id
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
        'id', c.id,
        'addressId', a.id,
        'custId', c.id,
        'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
        'companyclass', cc.tag,
        'gender', g.shortTag,
        'location', a.location,
        'city', a.city,
        'geometry', a.geometry,
        'postcode', a.postcode
      ),
      JSON_ARRAY()
      FROM customer c 
        INNER JOIN seo_object o USING(id) 
        INNER JOIN _results r USING(ref_id) 
        INNER JOIN `address` a ON c.addressId=a.id
        LEFT JOIN companyClass cc ON c.type = cc.id
        LEFT JOIN gender g ON g.id=c.gender
        WHERE o.table = 'customer';
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "poc") THEN
    REPLACE INTO _view SELECT 
      p.id, 
      r.word,
      r.relevance,
      'poc',
      JSON_OBJECT(
        'id', p.id,
        'pocId', p.id,
        'category', 'site',
        'gender', g.shortTag,
        'lastname', p.lastname,
        'firstname', p.firstname,
        'pocName', normalize_name(1, '', p.lastname, p.firstname) ,
        'email', p.email,
        'phones', p.phones
      ),
      JSON_ARRAY()
      FROM sitePoc p
        INNER JOIN seo_object o USING(id) 
        INNER JOIN _results r USING(ref_id)
        LEFT JOIN gender g ON g.id=p.gender
        WHERE o.table = 'sitePoc';
    REPLACE INTO _view SELECT 
      p.id, 
      r.word,
      r.relevance,
      'poc',
      JSON_OBJECT(
        'id', p.id,
        'pocId', p.id,
        'category', 'customer',
        'gender', g.shortTag,
        'lastname', p.lastname,
        'firstname', p.firstname,
        'pocName', normalize_name(1, '', p.lastname, p.firstname) ,
        'email', p.email,
        'phones', p.phones
      ),
      JSON_ARRAY()
      FROM customerPoc p
        INNER JOIN seo_object o USING(id) 
        INNER JOIN _results r USING(ref_id)
        LEFT JOIN gender g ON g.id=p.gender
        WHERE o.table = 'customerPoc';
  END IF;

  IF _tables IS NULL OR json_array_contains(_tables, "work") THEN
    REPLACE INTO _view SELECT 
      w.id, 
      r.word,
      r.relevance,
      'work',
      JSON_OBJECT(
        'id', w.id,
        'type',  wt.tag,
        'addressId', a.id,
        'siteId', s.id,
        'workId', w.id,
        'location', a.location,
        'description', w.description,
        'city', a.city,
        'postcode', a.postcode,
        'ctime', w.ctime
      ),
      JSON_ARRAY(
        JSON_OBJECT(
          'id', c.id,
          'custId', c.id,
          'addressId', ca.id,
          'gender', g.shortTag,
          'companyclass', cc.tag,
          'custName', normalize_name(c.category, c.company, c.lastname, c.firstname),
          'location', ca.location,
          'site', ca.location,
          'geometry', ca.geometry,
          'city', ca.city,
          'postcode', ca.postcode
        ),
        JSON_OBJECT(
          'id', s.id,
          'addressId', a.id,
          'siteId', s.id,
          'location', a.location,
          'geometry', a.geometry,
          'city', a.city,
          'postcode', a.postcode
        )
      )
      FROM work w
        INNER JOIN seo_object o USING(id) 
        INNER JOIN _results r USING(ref_id)
        INNER JOIN `site` s ON w.siteId=s.id AND w.custId=s.custId
        INNER JOIN workType wt ON w.category=wt.id
        INNER JOIN customer c ON c.id=w.custId
        INNER JOIN `address` a ON s.addressId=a.id
        INNER JOIN `address` ca ON c.addressId=ca.id
        LEFT JOIN gender g ON g.id=c.gender
        LEFT JOIN companyClass cc ON c.type = cc.id
        WHERE o.table = 'work';
  END IF;

  SELECT * FROM _view ORDER BY relevance LIMIT _offset ,_range;
END$

DELIMITER ;
