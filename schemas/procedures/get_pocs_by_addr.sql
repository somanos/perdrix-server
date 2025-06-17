

DELIMITER $

DROP PROCEDURE IF EXISTS `get_customer_pocs_by_addr`$
CREATE PROCEDURE `get_customer_pocs_by_addr`(
  IN _args JSON
)
BEGIN  
  DECLARE _postcode INTEGER;
  DECLARE _city VARCHAR(512);
  DECLARE _location JSON;
  DECLARE _page INTEGER DEFAULT 1;
  DECLARE _range bigint;
  DECLARE _offset bigint;

  SELECT IFNULL(JSON_VALUE(_args, "$.pagelength"), 45) INTO @rows_per_page;
  SELECT IFNULL(JSON_VALUE(_args, "$.page"), 1) INTO _page;
  SELECT IFNULL(JSON_VALUE(_args, "$.postcode"), 99999) INTO _postcode;
  SELECT IFNULL(JSON_VALUE(_args, "$.city"), "") INTO _city;
  SELECT JSON_EXTRACT(_args, "$.location") INTO _location;

  CALL yp.pageToLimits(_page, _offset, _range);

  SELECT p.* FROM customerPoc p INNER JOIN customer c 
    ON c.id=p.custId where 
      JSON_VALUE(c.location, "$[1]") = JSON_VALUE(_location, "$[1]") AND
      JSON_VALUE(c.location, "$[2]") = JSON_VALUE(_location, "$[2]") AND
      (postcode=_postcode OR city=_city) AND p.lastname != ''
    GROUP BY p.id ORDER BY p.lastname ASC LIMIT _offset ,_range;
END$

DELIMITER ;
