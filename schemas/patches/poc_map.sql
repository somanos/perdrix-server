


DROP TABLE IF EXISTS poc_map;
CREATE TABLE
poc_map (
  `pocId` int(10) unsigned NOT NULL,
  `category` enum('customer','site') DEFAULT 'customer',
  `custId` int(10) unsigned DEFAULT NULL, 
  `siteId` int(10) unsigned DEFAULT NULL, 
  `addressId` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY pk(pocId, custId, addressId, category)
);

insert into poc_map select p.id, 'customer', c.id, null, c.addressId 
  from customerPoc p inner join customer c on p.custId=c.id;
insert into poc_map select p.id, 'site', s.custId, s.id, s.addressId 
  from sitePoc p inner join site s on p.siteId=s.id;