DROP TABLE IF EXISTS travaux;
CREATE TABLE
  travaux (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    clientId INTEGER UNSIGNED,
    chantierId INTEGER UNSIGNED,
    categorie VARCHAR(200),
    `description` TEXT,
    ctime INT (11) UNSIGNED,
    statut INTEGER UNSIGNED,
    PRIMARY KEY (`id`)
  );