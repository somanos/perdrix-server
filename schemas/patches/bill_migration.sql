DROP TABLE IF EXISTS tmp_bill;
CREATE TABLE `tmp_bill` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `custId` int(10) unsigned DEFAULT NULL,
  `siteId` int(10) unsigned DEFAULT NULL,
  `workId` int(10) unsigned DEFAULT NULL,
  `serial` int(10) unsigned DEFAULT NULL,
  `chrono` varchar(128) GENERATED ALWAYS AS (concat(substr(`fiscalYear`,3),'.',lpad(`serial`,4,'0'))) VIRTUAL,
  `fiscalYear` int(11) DEFAULT NULL,
  `category` int(10) unsigned DEFAULT NULL,
  `ht` decimal(10,2) DEFAULT NULL,
  `tva` decimal(10,3) DEFAULT NULL,
  `ttc` decimal(10,2) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `docId` varchar(80) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT NULL,
  `ctime` int(11) unsigned DEFAULT NULL,
  `status` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chrono` (`chrono`),
  UNIQUE KEY `clientId` (`custId`,`workId`,`chrono`)
);

REPLACE INTO tmp_bill (`id`,
    `custId`,
    `siteId`,
    `workId`,
    `serial`,
    `fiscalYear`,
    `category`,
    `ht`,
    `tva`,
    `ttc`,
    `description`,
    `docId`,
    `ctime`,
    `status`
    )
SELECT     
    `id`,
    `custId`,
    `siteId`,
    `workId`,
    CAST(REGEXP_REPLACE(chrono,'^[0-9]{2,}\.', '') AS INTEGER),
    `fiscalYear`,
    `category`,
    `ht`,
    `tva`,
    `ttc`,
    `description`,
    `docId`,
    `ctime`,
    `status`
    FROM bill;
DROP TABLE IF EXISTS bill_bak;
CREATE TABLE `bill_bak` LIKE bill;
INSERT INTO bill_bak SELECT * FROM bill;
DROP TABLE IF EXISTS bill;
CREATE TABLE `bill` LIKE tmp_bill;
REPLACE INTO bill (`id`,
    `custId`,
    `siteId`,
    `workId`,
    `serial`,
    `fiscalYear`,
    `category`,
    `ht`,
    `tva`,
    `ttc`,
    `description`,
    `docId`,
    `ctime`,
    `status`
    )
SELECT     
    `id`,
    `custId`,
    `siteId`,
    `workId`,
    CAST(REGEXP_REPLACE(chrono,'^[0-9]{2,}\.', '') AS INTEGER),
    `fiscalYear`,
    `category`,
    `ht`,
    `tva`,
    `ttc`,
    `description`,
    `docId`,
    `ctime`,
    `status`
    FROM tmp_bill;
DROP TABLE IF EXISTS tmp_bill;