DROP TABLE IF EXISTS contactChantier;
CREATE TABLE
  contactChantier (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    clientId INTEGER UNSIGNED,
    chantierId INTEGER UNSIGNED,
    categorie VARCHAR(200),
    civilite INTEGER UNSIGNED,
    nom VARCHAR(200),
    prenom VARCHAR(200),
    email VARCHAR(200),
    telBureau VARCHAR(200),
    telDom VARCHAR(200),
    mobile VARCHAR(200),
    fax VARCHAR(200),
    ctime INT (11) UNSIGNED,
    actif VARCHAR(200),
    PRIMARY KEY (`id`)
  );