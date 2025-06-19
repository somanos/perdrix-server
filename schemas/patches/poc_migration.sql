
DROP TABLE IF EXISTS poc;
CREATE TABLE
  poc (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category` enum('customer','site') DEFAULT 'customer',
  `role` varchar(50) DEFAULT '',
  `gender` int(10) unsigned DEFAULT NULL,
  `lastname` varchar(200) NOT NULL,
  `firstname`varchar(200) DEFAULT '',
  `email` varchar(200) DEFAULT NULL,
  `office` varchar(200) DEFAULT NULL,
  `home` varchar(200) DEFAULT NULL,
  `mobile` varchar(200) DEFAULT NULL,
  `fax` varchar(200) DEFAULT NULL,
  `phones` JSON GENERATED ALWAYS AS (
    JSON_ARRAY(
      IFNULL(office,""),
      IFNULL(home,""),
      IFNULL(mobile,""),
      IFNULL(fax,"")
    )
  ) VIRTUAL,
  `ctime` int(11) unsigned DEFAULT NULL,
  `status` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phones` (`firstname`, `lastname`, `phones`) USING HASH
);


insert ignore into poc 
    (
    `category`,
    `role`,
    `gender`,
    `lastname`,
    `firstname`,
    `email`,
    `office`,
    `home`,
    `mobile`,
    `fax`,
    `ctime`,
    `status`
    )
    select
    'customer',
    `role`,
    `gender`,
    `lastname`,
    `firstname`,
    `email`,
    IFNULL(JSON_VALUE(phones, "$[0]"), ""), 
    IFNULL(JSON_VALUE(phones, "$[1]"), ""), 
    IFNULL(JSON_VALUE(phones, "$[2]"), ""), 
    IFNULL(JSON_VALUE(phones, "$[3]"), ""),
    ctime,
    status
from customerPoc;

insert ignore into poc 
    (
    `category`,
    `role`,
    `gender`,
    `lastname`,
    `firstname`,
    `email`,
    `office`,
    `home`,
    `mobile`,
    `fax`,
    `ctime`,
    `status`
    )
    select
    'site',
    `role`,
    `gender`,
    `lastname`,
    `firstname`,
    `email`,
    IFNULL(JSON_VALUE(phones, "$[0]"), ""), 
    IFNULL(JSON_VALUE(phones, "$[1]"), ""), 
    IFNULL(JSON_VALUE(phones, "$[2]"), ""), 
    IFNULL(JSON_VALUE(phones, "$[3]"), ""),
    ctime,
    0
FROM sitePoc;


DROP TABLE IF EXISTS poc_map;
CREATE TABLE
poc_map (
  `pocId` int(10) unsigned NOT NULL,
  `category` enum('customer','site') DEFAULT 'customer',
  `custId` int(10) unsigned DEFAULT NULL, 
  `siteId` int(10) unsigned DEFAULT NULL, 
  `addressId` int(10) unsigned DEFAULT NULL
);

insert into poc_map select p.id, 'customer', c.id, null, c.addressId from customerPoc p inner join customer c on p.custId=c.id;
insert into poc_map select p.id, 'site', s.custId, s.id, s.addressId from sitePoc p inner join site s on p.siteId=s.id;