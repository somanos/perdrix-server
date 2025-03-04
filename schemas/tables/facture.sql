DROP TABLE IF EXISTS facture;
CREATE TABLE
  facture (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    numero INTEGER UNSIGNED,
    clientId INTEGER UNSIGNED,
    chantierId INTEGER UNSIGNED,
    travauxId INTEGER UNSIGNED,
    chrono VARCHAR(200),
    categorie INTEGER UNSIGNED,
    ht DECIMAL(10, 2),
    tva DECIMAL(10, 2),
    ttc DECIMAL(10, 2),
    `description` TEXT,
    docId VARCHAR(16),
    ctime INT (11) UNSIGNED,
    statut VARCHAR(200),
    PRIMARY KEY (`id`),
    UNIQUE KEY (`chrono`)
  );