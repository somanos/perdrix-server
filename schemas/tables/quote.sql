DROP TABLE IF EXISTS quote;

CREATE TABLE
  quote (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `custId` int (10) unsigned DEFAULT NULL,
    `siteId` int (10) unsigned DEFAULT NULL,
    `workId` int (10) unsigned DEFAULT NULL,
    `serial` int (10) unsigned DEFAULT NULL,
    `version` varchar(80) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT 'A',
    `fiscalYear` int(11) DEFAULT NULL,
    `chrono` varchar(128) GENERATED ALWAYS AS (
      CONCAT(SUBSTRING(fiscalYear, 3), '.', LPAD(`serial`, 4, '0'), `version`)
     ) VIRTUAL,
    `description` text DEFAULT NULL,
    `ht` decimal(10, 2) DEFAULT NULL,
    `tva` decimal(10, 3) DEFAULT NULL,
    `ttc` decimal(10, 2) DEFAULT NULL,
    `discount` decimal(10, 2) DEFAULT NULL,
    `docId` varchar(80) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT NULL,
    `ctime` int (11) unsigned DEFAULT NULL,
    `status` int (10) unsigned DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `chrono` (`chrono`),
    UNIQUE KEY `clientId` (`custId`, `workId`, `chrono`)
  );

