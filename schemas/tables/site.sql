DROP TABLE IF EXISTS `site`;
CREATE TABLE
  `site` (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `custId` int (10) unsigned DEFAULT NULL,
    `location` JSON,
    `postcode` int (10) unsigned DEFAULT NULL,
    `citycode` varchar(200) DEFAULT NULL,
    `city` text DEFAULT NULL,
    `countrycode` int (10) unsigned DEFAULT NULL,
    `geometry` JSON,
    `ctime` int (11) unsigned DEFAULT NULL,
    `statut` int (10) unsigned DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`, `custId`)
  );