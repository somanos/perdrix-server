
const { Mariadb } = require('@drumee/server-essentials');
const { exit, env } = process;
const Perdrix = new Mariadb({ name: 'perdrix', user: 'root' });
const { isArray } = require('lodash');

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
async function populate_customer() {
  let rows = await Perdrix.await_query(`SELECT * FROM customer`);

  for (let row of rows) {
    let custName = row.lastname || row.company;
    let { id } = row;
    let reference = {
      id, table: 'customer', db: 'perdrix'
    }
    if (row.firstname) custName = `${custName} ${row.firstname}`;
    if (custName) {
      await Perdrix.await_proc(`seo_index`, custName, 'custName', reference);
    }
    if (row.city) {
      await Perdrix.await_proc(`seo_index`, row.city, 'city', reference);
    }
    if (row.location) {
      let streetName = row.location[2];
      if (streetName) {
        await Perdrix.await_proc(`seo_index`, streetName, 'streetName', reference);
      }
    }
  }
}

/**
 * 
 * @returns 
 */
async function populate_site() {
  let rows = await Perdrix.await_query(`SELECT * FROM site`);
  for (let row of rows) {
    let { id } = row;
    let reference = {
      id, table: 'site', db: 'perdrix'
    }
    if (row.location) {
      let streetName = row.location[2];
      if (streetName) {
        await Perdrix.await_proc(`seo_index`, streetName, 'streetName', reference);
      }
    }
    if (row.city) {
      await Perdrix.await_proc(`seo_index`, row.city, 'city', reference);
    }
  }
}

/**
 * 
 * @returns 
 */
async function populate_poc() {
  let rows = await Perdrix.await_query(`SELECT * FROM poc`);
  for (let row of rows) {
    let { id } = row;
    let reference = {
      id, table: 'poc', db: 'perdrix'
    }
    let pocName = row.lastname;
    if (row.firstname) pocName = `${pocName} ${row.firstname}`;
    if (pocName) {
      await Perdrix.await_proc(`seo_index`, pocName, 'pocName', reference);
    }

    if (isArray(row.phones)) {
      for (let p of row.phones) {
        p = p.replace(/ +/g, '');
        await Perdrix.await_proc(`seo_index`, p, 'phone', reference);
      }
    }
  }
}
/**
 * 
 * @returns 
 */
async function populate_work() {
  let rows = await Perdrix.await_query(`SELECT * FROM work`);
  for (let row of rows) {
    let { id } = row;
    let reference = {
      id, table: 'work', db: 'perdrix'
    }
    let words = row.description.split(/[ \.,;\/\:]+/);
    let line = '';
    for (let word of words) {
      line = `${line} ${word}`;
      if (line.length > 1000) {
        await Perdrix.await_proc(`seo_index`, line, 'description', reference);
        line = '';
      }
    }
    if (line.length) {
      await Perdrix.await_proc(`seo_index`, line, 'description', reference);
    }
  }
}


/**
 * 
 * @returns 
 */
async function populate() {

  // await populate_customer();
  // await populate_site();
  // await populate_poc();
  await populate_work();

}

/**
 * 
 */
populate().then(async (rows) => {
  setTimeout(() => {
    exit();
  }, 500)
})
