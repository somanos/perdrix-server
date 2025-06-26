DELIMITER $

DROP PROCEDURE IF EXISTS `search_by_address`$
CREATE PROCEDURE `search_by_address`(
  IN _args JSON
)
BEGIN
  DECLARE _key TEXT;
  DECLARE _offset INTEGER UNSIGNED;
  DECLARE _range INTEGER UNSIGNED;
  DECLARE _serial VARCHAR(20);
  DECLARE _version VARCHAR(20);
  DECLARE _fiscalYear INTEGER UNSIGNED;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'lastname';
  DECLARE _hub_id VARCHAR(20);
  DECLARE _words TEXT;
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;


  SELECT IFNULL(JSON_VALUE(_args, "$.sort_by"), 'lastname') INTO _sort_by;
  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'asc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.words"), "") INTO _words;
  SELECT JSON_VALUE(_args, "$.serial") INTO _serial;
  SELECT JSON_VALUE(_args, "$.version") INTO _version;
  SELECT JSON_VALUE(_args, "$.fiscalYear") INTO _fiscalYear;

  CALL yp.pageToLimits(_page, _offset, _range);
  SELECT id FROM yp.entity WHERE db_name=database() INTO _hub_id;

  SELECT REGEXP_REPLACE(_words, '^ +| +$', '') INTO _key;
  SELECT REGEXP_REPLACE(_key, ' +', ',') INTO _key;
  DROP TABLE IF EXISTS _results;
  CREATE TEMPORARY TABLE _results(
    `ikey` text DEFAULT NULL,
    `ref_id` varchar(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
    `word` TEXT NOT NULL,
    `relevance` double DEFAULT 0
  );


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

  REPLACE INTO _view SELECT 
    a.id, 
    r.word,
    r.relevance,
    'address',
    JSON_OBJECT(
      'addressId', a.id,
      'location', a.location,
      'city', a.city,
      'geometry', a.geometry,
      'postcode', a.postcode
    ),
    JSON_ARRAY()
    FROM address a
      INNER JOIN seo_object o USING(id) 
      INNER JOIN _results r USING(ref_id);

  SELECT * FROM _view ORDER BY word, relevance DESC LIMIT _offset ,_range;
END$

DELIMITER ;
