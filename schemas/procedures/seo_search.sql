
DELIMITER $

DROP PROCEDURE IF EXISTS `seo_search`$
CREATE PROCEDURE `seo_search`(
  _words TEXT,
  _page INTEGER
)
BEGIN
  DECLARE _key TEXT;
  DECLARE _offset INTEGER UNSIGNED;
  DECLARE _range INTEGER UNSIGNED;

  DROP TABLE IF EXISTS _results;

  CALL yp.pageToLimits(_page, _offset, _range);
  SELECT REGEXP_REPLACE(_words, '^ +| +$', '') INTO _key;
  SELECT REGEXP_REPLACE(_key, ' +', ',') INTO _key;
  
  CREATE TEMPORARY TABLE _results AS
    SELECT _key ikey, ref_id, word, MATCH(word) AGAINST(_key) relevance 
      FROM seo WHERE MATCH(word) AGAINST (_key IN BOOLEAN mode) 
      ORDER BY relevance DESC LIMIT _offset, _range;
  SELECT o.*, o.table kind FROM seo_object o INNER JOIN _results r USING(ref_id);
END$

DELIMITER ;
