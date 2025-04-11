
DELIMITER $

DROP PROCEDURE IF EXISTS `quote_get`$
CREATE PROCEDURE `quote_get`(
  IN _id INTEGER
)
BEGIN
  SELECT 
    *,
    id quoteId
    FROM `quotation` s
      WHERE s.id = _id;
END$

DELIMITER ;
