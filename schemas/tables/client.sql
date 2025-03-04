DROP TABLE IF EXISTS client;
CREATE TABLE
  client (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    categorie INTEGER UNSIGNED,
    titre INTEGER UNSIGNED,
    societe VARCHAR(200),
    genre INTEGER UNSIGNED,
    nom TEXT,
    prenom TEXT,
    numVoie VARCHAR(200),
    codeVoie VARCHAR(200),
    nomVoie VARCHAR(200),
    nomVoie2 VARCHAR(200),
    codePostal VARCHAR(200),
    localite TEXT,
    codePays INTEGER UNSIGNED,
    ctime INT(11) UNSIGNED,
    PRIMARY KEY (`id`)
  );