DROP TABLE IF EXISTS `site`;

CREATE TABLE
  `site` (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `custId` int (10) unsigned DEFAULT NULL,
    `countrycode` int (10) unsigned DEFAULT NULL,
    `location` longtext CHARACTER
    SET
      utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid (`location`)),
      `postcode` int (10) unsigned DEFAULT NULL,
      `city` text DEFAULT NULL,
      `lattitude` double DEFAULT NULL,
      `longitude` double DEFAULT NULL,
      `ctime` date DEFAULT NULL,
      `statut` int (10) unsigned DEFAULT NULL,
      PRIMARY KEY (`id`),
      UNIQUE KEY `id` (`id`, `custId`)
  );