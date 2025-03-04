DROP TABLE IF EXISTS payeur;
CREATE TABLE
  payeur (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    clientId INTEGER UNSIGNED,
    factureId INTEGER UNSIGNED,
    categorie INTEGER UNSIGNED,
    titre INTEGER UNSIGNED,
    nom VARCHAR(200),
    prenom VARCHAR(200),
    email VARCHAR(200),
    telBureau VARCHAR(200),
    telDom VARCHAR(200),
    mobile VARCHAR(200),
    fax VARCHAR(200),
    ctime INT(11) UNSIGNED,
    actif INTEGER UNSIGNED,
    PRIMARY KEY (`id`)
  );