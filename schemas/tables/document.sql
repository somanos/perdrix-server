DROP TABLE IF EXISTS document;
 CREATE TABLE `document` (
  `id` varchar(16) CHARSET ascii DEFAULT NULL,
  `noteId` int(10) unsigned DEFAULT NULL,
  `category` varchar(200) DEFAULT NULL,
  `ctime` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) 