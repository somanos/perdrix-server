DROP TABLE IF EXISTS site_poc;
CREATE TABLE `site_poc` (
  `pocId` int(10) unsigned NOT NULL,
  `custId` int(10) unsigned NOT NULL,
  `siteId` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`pocId`,`siteId`)
);
