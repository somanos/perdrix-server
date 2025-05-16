DROP TABLE IF EXISTS bill;

CREATE TABLE
  bill (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `billNumber` int (10) unsigned NOT NULL,
    `custId` int (10) unsigned DEFAULT NULL,
    `siteId` int (10) unsigned DEFAULT NULL,
    `workId` int (10) unsigned DEFAULT NULL,
    `chrono` varchar(200) DEFAULT NULL,
    `fiscalYear` int(11) DEFAULT NULL,
    `category` int(10) unsigned DEFAULT NULL,
    `ht` decimal(10, 2) DEFAULT NULL,
    `tva` decimal(10, 3) DEFAULT NULL,
    `ttc` decimal(10, 2) DEFAULT NULL,
    `description` text DEFAULT NULL,
    `docId` varchar(80) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT NULL,
    `ctime` int (11) unsigned DEFAULT NULL,
    `status` int (10) unsigned DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `chrono` (`chrono`),
    UNIQUE KEY `billNumber` (`billNumber`),
    UNIQUE KEY `clientId` (`custId`, `workId`, `chrono`)
  );
