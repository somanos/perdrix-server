DROP TABLE IF EXISTS `site`;

CREATE TABLE
  `site` (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `custId` int (10) unsigned DEFAULT NULL,
    `countrycode` int (10) unsigned DEFAULT NULL,
    `location` JSON,
    `postcode` int (10) unsigned DEFAULT NULL,
    `city` text DEFAULT NULL,
    `lattitude` double DEFAULT NULL,
    `longitude` double DEFAULT NULL,
    `ctime` date DEFAULT NULL,
    `statut` int (10) unsigned DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`, `custId`)
  );