
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
    // await Perdrix.await_proc(`seo_index`, nom, 'nom', reference);
    await Perdrix.await_proc(`seo_index`, row.nomVoie, 'nomVoie', reference);
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
