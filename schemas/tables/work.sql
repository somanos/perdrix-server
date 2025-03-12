DROP TABLE IF EXISTS travaux;
 CREATE TABLE `travaux` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `custId` int(10) unsigned DEFAULT NULL,
  `siteId` int(10) unsigned DEFAULT NULL,
  `category` varchar(200) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `ctime` int(11) unsigned DEFAULT NULL,
  `status` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) 