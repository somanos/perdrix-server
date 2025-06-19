
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_list`$
CREATE PROCEDURE `poc_list`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _addressId INTEGER ;
  DECLARE _lastname VARCHAR(20) DEFAULT 'desc';
  DECLARE _order VARCHAR(20) DEFAULT 'desc';

  SELECT IFNULL(JSON_VALUE(_args, "$.order"), 'desc') INTO _order;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;

  SELECT JSON_VALUE(_args, "$.lastname") INTO _lastname;
  SELECT JSON_VALUE(_args, "$.addressId") INTO _addressId;

  CALL yp.pageToLimits(_page, _offset, _range);
  DROP TABLE IF EXISTS _view;
  CREATE TEMPORARY TABLE _view AS
  SELECT
    p.id,
    'customer' category,
    c.addressId,
    p.role,
    g.shortTag gender,
    p.lastname,
    p.firstname,
    p.phones,
    _page `page`
  FROM customerPoc p 
    INNER JOIN customer c ON c.id=custId
    INNER JOIN gender g ON p.gender=g.id 
    WHERE 
      IF (_lastname IS NULL, 1, p.lastname REGEXP _lastname) AND
      IF (_addressId IS NULL, 1, c.addressId=_addressId);
  INSERT INTO _view SELECT
    p.id,
    'site' category,
    s.addressId,
    p.role,
    g.shortTag gender,
    p.lastname,
    p.firstname,
    p.phones,
    _page `page`
  FROM sitePoc p 
    INNER JOIN site s ON s.id=p.siteId
    INNER JOIN gender g ON p.gender=g.id 
    WHERE 
      IF (_lastname IS NULL, 1, p.lastname REGEXP _lastname) AND
      IF (_addressId IS NULL, 1, s.addressId=_addressId);

  SELECT * FROM _view ORDER BY
    CASE WHEN LCASE(_order) = 'asc' THEN lastname END ASC,
    CASE WHEN LCASE(_order) = 'desc' THEN lastname END DESC
    LIMIT _offset ,_range;
END$


-- DROP PROCEDURE IF EXISTS `poc_list`$
-- CREATE PROCEDURE `poc_list`(
--   IN _args JSON
-- )
-- BEGIN
--   DECLARE _range bigint;
--   DECLARE _offset bigint;
--   DECLARE _page INTEGER DEFAULT 1;
--   DECLARE _filter JSON ;
--   DECLARE _i TINYINT(6) unsigned DEFAULT 0;

--   SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO @_page;
--   SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;  
--   CALL yp.pageToLimits(_page, _offset, _range);

--   SELECT JSON_EXTRACT(_args, "$.filter") INTO _filter;

--   SET @stm = "ORDER BY";
--   IF JSON_TYPE(_filter) = 'ARRAY' AND JSON_LENGTH(_filter)>0 THEN 
--     WHILE _i < JSON_LENGTH(_filter) DO 
--       SELECT JSON_EXTRACT(_filter, CONCAT("$[", _i, "]")) INTO @r;
--       SELECT JSON_VALUE(@r, "$.name") INTO @_name;
--       SELECT JSON_VALUE(@r, "$.value") INTO @_value;
--       SELECT CONCAT(@stm, " ", @_name, " ", @_value) INTO @stm;
--       IF(_i < JSON_LENGTH(_filter) - 1) THEN
--         SELECT CONCAT(@stm, ",") INTO @stm;
--       END IF;
--       SELECT _i + 1 INTO _i;
--     END WHILE;
--   ELSE
--     SELECT CONCAT(@stm, " ", "lastname asc") INTO @stm;
--   END IF;

--   SET @stm = CONCAT("SELECT ",
--     "p.id, lastname, firstname, email, phones, p.id pocId, ",
--     "g.shortTag gender, @_page page ",
--     "FROM poc p INNER JOIN gender g ON p.gender = g.id ", 
--     @stm, " ", "LIMIT ?, ?"
--   );

--   PREPARE stmt FROM @stm;
--   EXECUTE stmt USING _offset, _range;
--   DEALLOCATE PREPARE stmt;

-- END$

DELIMITER ;
