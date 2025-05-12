
DELIMITER $

DROP PROCEDURE IF EXISTS `site_list`$
CREATE PROCEDURE `site_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER;
  DECLARE _filter JSON ;
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;

  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO @_page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(@_page, _offset, _range);

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_EXTRACT(_args, "$.filter") INTO _filter;

  SET @stm = "ORDER BY";
  IF JSON_TYPE(_filter) = 'ARRAY' AND JSON_LENGTH(_filter)>0 THEN 
    WHILE _i < JSON_LENGTH(_filter) DO 
      SELECT JSON_EXTRACT(_filter, CONCAT("$[", _i, "]")) INTO @r;
      SELECT JSON_VALUE(@r, "$.name") INTO @_name;
      SELECT JSON_VALUE(@r, "$.value") INTO @_value;
      SELECT CONCAT(@stm, " ", @_name, " ", @_value) INTO @stm;
      IF(_i < JSON_LENGTH(_filter) - 1) THEN
        SELECT CONCAT(@stm, ",") INTO @stm;
      END IF;
      SELECT _i + 1 INTO _i;
    END WHILE;
  ELSE
    SELECT CONCAT(@stm, " ", "city asc, street asc, housenumber desc") INTO @stm;
  END IF;
  DROP TABLE IF EXISTS `_site`;
  CREATE TEMPORARY TABLE `_site` (
    `id` int(10) unsigned,
    `location` JSON,
    `page` int(11) unsigned DEFAULT 1,
    `street` varchar(200) DEFAULT "",
    `housenumber` INTEGER DEFAULT NULL,
    PRIMARY KEY (`id`)
  );

  INSERT INTO _site SELECT 
    `id`,
    `location`,
     @_page,
    REGEXP_REPLACE(JSON_VALUE(location, "$[2]"), "^(de +la +|des +|de +l\'|du +|la +|le +|de +)", ""),
    CAST(REGEXP_REPLACE(IF(JSON_VALUE(location, "$[0]")="", 0, JSON_VALUE(location, "$[0]")), " *([0-9]+).*$", "\\1")  AS INTEGER)
  FROM `site` WHERE custId=_custId;

  SET @stm = CONCAT(
    'SELECT s.*, page FROM site s INNER JOIN _site USING(id) WHERE custId=? ',
    @stm, " ", "LIMIT ?, ?"
  );
  PREPARE stmt FROM @stm;
  EXECUTE stmt USING _custId, _offset, _range;
  DEALLOCATE PREPARE stmt;

END$

DELIMITER ;
