DROP TABLE IF EXISTS travaux;
 CREATE TABLE `travaux` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `clientId` int(10) unsigned DEFAULT NULL,
  `chantierId` int(10) unsigned DEFAULT NULL,
  `categorie` varchar(200) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `ctime` int(11) unsigned DEFAULT NULL,
  `statut` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) 