DROP TABLE IF EXISTS devis;

CREATE TABLE
  devis (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    clientId INTEGER UNSIGNED,
    chantierId INTEGER UNSIGNED,
    travauxId INTEGER UNSIGNED,
    chrono VARCHAR(200),
    `description` TEXT,
    ht DECIMAL(10, 2),
    tva DECIMAL(10, 2),
    ttc DECIMAL(10, 2),
    remis DECIMAL(10, 2),
    folderId VARCHAR(80) CHARACTER SET ascii COLLATE ascii_general_ci,
    ctime INT (11) UNSIGNED,
    statut INTEGER UNSIGNED,
    PRIMARY KEY (`id`),
    UNIQUE KEY (`chrono`),
    UNIQUE KEY (`clientId`, `travauxId`)
  );