
const { Mariadb } = require('@drumee/server-essentials');
const { exit, env } = process;
const args = require("./args");
if(!args.db){
  console.error("Require db nqme")
  exit(1)
}
const Perdrix = new Mariadb({ name: args.db, user: 'root' });
const { isArray } = require('lodash');


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
      id, table: 'customer',
    }
    if (row.firstname) custName = `${custName} ${row.firstname}`;
    if (custName) {
      await Perdrix.await_proc(`seo_index`, custName, 'custName', reference);
    }
    // if (row.city) {
    //   await Perdrix.await_proc(`seo_index`, row.city, 'city', reference);
    // }
    // if (row.location) {
    //   let streetName = row.location[2];
    //   if (streetName) {
    //     await Perdrix.await_proc(`seo_index`, streetName, 'streetName', reference);
    //   }
    // }
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
      id, table: 'site',
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
async function populate_address() {
  let rows = await Perdrix.await_query(`SELECT * FROM address`);
  for (let row of rows) {
    let { id } = row;
    let reference = {
      id, table: 'address',
    }
    if (row.location) {
      let streetName = row.location.join(' ');
      if (row.streetname) {
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
async function populate_poc(table) {
  let rows = await Perdrix.await_query(`SELECT * FROM ${table}`);
  for (let row of rows) {
    let { id } = row;
    let reference = {
      id, table: 'poc',
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
    /** Index customer as well */
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
      id, table: 'work',
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

  await populate_customer();
  await populate_address();
  await populate_poc("customerPoc");
  await populate_poc("sitePoc");
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
