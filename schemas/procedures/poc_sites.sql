
DELIMITER $

DROP PROCEDURE IF EXISTS `poc_sites`$
CREATE PROCEDURE `poc_sites`(
  IN _args JSON
)
BEGIN
  DECLARE _range bigint;
  DECLARE _offset bigint;
  DECLARE _sort_by VARCHAR(20) DEFAULT 'name';
  DECLARE _order VARCHAR(20) DEFAULT 'asc';
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _custId INTEGER ;
  DECLARE _siteId INTEGER ;
  DECLARE _id INTEGER ;
  DECLARE _i TINYINT(6) unsigned DEFAULT 0;


  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT JSON_VALUE(_args, "$.custId") INTO _custId;
  SELECT JSON_VALUE(_args, "$.id") INTO _id;
  SELECT JSON_VALUE(_args, "$.siteId") INTO _siteId;
  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT
    s.countrycode,
    s.location,
    s.postcode,
    s.city,
    s.lat,
    s.lon,
    s.ctime,
    s.statut
  FROM `site` s
    WHERE s.custId = _custId
    LIMIT _offset ,_range;
END$

DELIMITER ;
