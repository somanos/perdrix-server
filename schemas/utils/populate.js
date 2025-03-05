
const { Mariadb } = require('@drumee/server-essentials');
const { exit, env } = process;
const Perdrix = new Mariadb({ name: 'perdrix', user: env.USER });
const { basename, extname, join } = require('path');

const {
  writeSync,
  openSync,
  closeSync,
  existsSync,
  createReadStream
} = require('fs');
const { createInterface } = require("readline");
const events = require("events");



/**
 * 
 * @returns 
 */
async function populate() {
  let rows = await Perdrix.await_query(`SELECT * FROM client`);

  for (let row of rows) {
    let nom = row.nom || row.societe;
    let { id } = row;
    let reference = {
      id, table: 'client', db: 'perdrix'
    }
    let word = `${nom}`;
    if(row.prenom)  word = `${nom} ${row.prenom}`;
    await Perdrix.await_proc(`seo_index`, word, 'nom', reference);
    await Perdrix.await_proc(`seo_index`, row.nomVoie, 'nomVoie', reference);
  }

  // let rows = await Perdrix.await_query(`SELECT * FROM chantier`);

  // for (let row of rows) {
  //   let nom = row.nom || row.societe;
  //   let { id } = row;
  //   let reference = {
  //     id, table: 'chantier', db: 'perdrix'
  //   }
  //   await Perdrix.await_proc(`seo_index`, row.nomVoie, 'nomVoie', reference);
  // }

  rows = await Perdrix.await_query(`SELECT * FROM contactChantier`);

  for (let row of rows) {
    let { id } = row;
    let reference = {
      id, table: 'contactChantier', db: 'perdrix'
    }
    let word = `${row.nom}`;
    if(row.prenom)  word = `${row.nom} ${row.prenom}`;
    await Perdrix.await_proc(`seo_index`, word, 'nom', reference);
  }
}

/**
 * 
 */
populate().then(async (rows) => {
  setTimeout(() => {
    exit();
  }, 500)
})
