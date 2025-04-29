
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

  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_EXTRACT(_args, "$.filter") INTO _filter;

  DROP TABLE IF EXISTS _view;
  CREATE TEMPORARY TABLE _view LIKE `site`;
  ALTER TABLE _view ADD column `page` BIGINT;
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
    SELECT CONCAT(@stm, " ", "ctime desc") INTO @stm;
  END IF;

  INSERT INTO _view SELECT
    *,
    _page `page`
  FROM `site`
    WHERE custId=_custId
    LIMIT _offset ,_range;

  SET @stm = CONCAT("SELECT * FROM _view", " ", @stm);
  PREPARE stmt FROM @stm;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

END$

DELIMITER ;
