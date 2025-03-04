DROP TABLE IF EXISTS chantier;
CREATE TABLE chantier (
  id INTEGER UNSIGNED AUTO_INCREMENT,
  clientId INTEGER UNSIGNED, 
  codePays INTEGER UNSIGNED, 
  codePostal INTEGER UNSIGNED, 
  localite TEXT, 
  numVoie VARCHAR(200), 
  codeVoie INTEGER UNSIGNED, 
  nomVoie TEXT, 
  nomVoie2 TEXT,
  etage VARCHAR(200), 
  appartement VARCHAR(200), 
  autre TEXT, 
  lattitude DOUBLE, 
  longitude DOUBLE, 
  ctime date, 
  statut INTEGER UNSIGNED,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`id`, `clientId`)
);
