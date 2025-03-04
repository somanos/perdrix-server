DROP TABLE IF EXISTS paiement;
CREATE TABLE
  paiement (
    id INTEGER UNSIGNED AUTO_INCREMENT,
    clientId INTEGER UNSIGNED,
    chantierId INTEGER UNSIGNED,
    travauxId INTEGER UNSIGNED,
    factureId INTEGER UNSIGNED,
    factureType INTEGER UNSIGNED,
    factureChrono VARCHAR(80) CHARACTER SET ascii COLLATE ascii_general_ci,
    ctime INT (11) UNSIGNED,
    banqueDebit INTEGER UNSIGNED,
    banqueCredit INTEGER UNSIGNED,
    categorie INTEGER UNSIGNED,
    transactId INTEGER UNSIGNED,
    autorisationId INTEGER UNSIGNED,
    montant DECIMAL(10, 2),
    PRIMARY KEY (`id`)
  );