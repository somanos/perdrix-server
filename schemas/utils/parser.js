
const { Mariadb } = require('@drumee/server-essentials');
const { exit, env } = process;
const args = require("./args");

const Perdrix = new Mariadb({ name: args.db, user: "root" });
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
 * @param {*} colunms 
 * @param {*} src 
 * @param {*} dest 
 */
function createTable(colunms, src, dest) {
  let re = new RegExp(`${extname(src)}$`)
  let name = basename(src).replace(re, '')
  console.log(`Reading data from ${src}`, name)

  let stm = [`DROP TABLE IF EXISTS ${name}`];
  stm.push(`CREATE TABLE ${name} (`);
  for (let c of colunms) {
    stm.push(`  ${c} VARCHAR(200), `)
  }
  stm[stm.length - 1] = stm[stm.length - 1].replace(/\, $/, '')
  stm.push(');');
  let outfile = join(dest, `${name}.sql`);
  let fd = openSync(outfile, "w+");
  for (let l of stm) {
    writeSync(fd, l + '\n');
  }
  closeSync(fd)
}

/***  
 * 
 */
function parseTable(row, sql, types) {
  let orig = {...row}
  for (let i = 0; i < types.length; i++) {
    sql = `${sql} ?,`;
    if (/^int/.test(types[i])) {
      if (/\(11\)/.test(types[i])) {
        let t = row[i] || '2000-01-01';
        if(/[0-9]{4,4}\-[0-9]{2,2}\-[0-9]{2,2}/.test(t)){
          row[i] = new Date(t).getTime() / 1000;
        }else{
          row[i] = new Date('2000-01-01').getTime() / 1000;
        }
        if(row[i]<0){
          row[i] = 0;
        }
      } else {
        row[i] = parseInt(row[i]) || 0
      }
    } else if (/^(double|decimal)/i.test(types[i])) {
      if (row[i] == null) row[i] = '0.0';
      let [val, dum] = row[i].split(/ +/)
      row[i] = row[i].replace(/ .*$/, '');
      row[i] = row[i].replace(/\,/g, '');
      row[i] = parseFloat(row[i]) || 0
    } else if (/^date/.test(types[i])) {
      row[i] = row[i] || '2000-01-01';
    } else if (!row[i]) {

    }
  }
  sql = sql.replace(/\, *$/, ')');
  return { sql, row, types, orig }

}


/**
 * 
 * @returns 
 */
async function inject(src, dest) {
  let re = new RegExp(`${extname(src)}$`)
  let name = basename(src).replace(re, '')
  console.log(`Reading data from ${src}`, name)
  let table = await Perdrix.await_query(`explain ${name}`);
  let fields = [];
  let types = [];
  let sql = `REPLACE INTO ${name} (`;
  for (let c of table) {
    sql = `${sql} ${c.Field}, `;
    fields.push(c.Field);
    types.push(c.Type);
  }
  console.log({fields, types})
  sql = sql.replace(/\, *$/, ') VALUES(')
  let stm = [];
  try {
    if (!existsSync(src)) {
      console.error(`File ${src} not found!`);
      exit(1);
    }
    const rl = createInterface({
      input: createReadStream(src),
      crlfDelay: Infinity,
    });

    let first = 1;
    rl.on("line", async (line) => {
      let d = line.split('|');
      if (first) {
        first = 0;
        return;
      }
      stm.push(parseTable(d, sql, types));
    });
    await events.once(rl, "close");
    for (let item of stm) {
      console.log(item)
      let r = await Perdrix.await_query(item.sql, ...item.row);
      if (!r) {
        exit(0)
      }
    }
  } catch (err) {
    console.error(err);
  }
}

module.exports = {
  inject,
  createTable,
  parseTable
}
