
DELIMITER $

DROP PROCEDURE IF EXISTS `seo_populate_client`$
CREATE PROCEDURE `seo_populate_client`(
)
BEGIN
  DECLARE _seq INTEGER DEFAULT 0;
  DECLARE _htype INTEGER DEFAULT 0;
  DECLARE _limit INTEGER DEFAULT 1;
  DECLARE _half INTEGER DEFAULT 1;
  DECLARE _finished INTEGER DEFAULT 0;
  DECLARE dbcursor CURSOR FOR 
    SELECT nom, prenom, nomVoie, nomVoie2, societe, 
  FROM client GROUP BY htype;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1; 

  OPEN dbcursor;
  STARTLOOP: LOOP
    FETCH dbcursor INTO _htype;
    IF _finished = 1 THEN 
      LEAVE STARTLOOP;
    END IF;
  END LOOP STARTLOOP;

END$

DELIMITER ;
