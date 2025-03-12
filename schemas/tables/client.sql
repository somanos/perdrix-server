DROP TABLE IF EXISTS client;

CREATE TABLE
  client (
    `id` int (10) unsigned NOT NULL AUTO_INCREMENT,
    `categorie` int (10) unsigned DEFAULT NULL,
    `type` int (10) unsigned DEFAULT NULL,
    `societe` varchar(200) DEFAULT NULL,
    `genre` int (10) unsigned DEFAULT NULL,
    `nom` text DEFAULT NULL,
    `prenom` text DEFAULT NULL,
    `numVoie` varchar(200) DEFAULT NULL,
    `codeVoie` varchar(200) DEFAULT NULL,
    `nomVoie` varchar(200) DEFAULT NULL,
    `nomVoie2` varchar(200) DEFAULT NULL,
    `codePostal` varchar(200) DEFAULT NULL,
    `localite` text DEFAULT NULL,
    `codePays` int (10) unsigned DEFAULT NULL,
    `ctime` int (11) unsigned DEFAULT NULL,
    PRIMARY KEY (`id`)
  );