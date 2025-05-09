
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_list`$
CREATE PROCEDURE `poc_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _filter JSON ;

  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO @_page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
  CALL yp.pageToLimits(_page, _offset, _range);

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
    SELECT CONCAT(@stm, " ", "ctime desc") INTO @stm;
  END IF;

  SET @stm = CONCAT(
    "SELECT p.*, p.id pocId, g.shortTag gender, @_page page FROM poc p ", 
    "INNER JOIN gender g ON p.gender = g.id ", @stm, " ", "LIMIT ?, ?"
  );

  PREPARE stmt FROM @stm;
  EXECUTE stmt USING _offset, _range;
  DEALLOCATE PREPARE stmt;

END$

DELIMITER ;
