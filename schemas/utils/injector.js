
const { Mariadb } = require('@drumee/server-essentials');
const { exit, env } = process;
// const Loto = new Mariadb({ name: 'longchamp', user: env.USER });
const { basename, extname, resolve } = require('path');

const {

  inject,
  
} = require('./parser')
const args = require("./args");

let src;
let output;

if (/^\//.test(args.source)) {
  src = args.source;
} else {
  src = resolve(__dirname, args.source);
}

/**
 * 
 */
inject(src, output).then(async (rows) => {
  setTimeout(() => {
    exit();
  }, 500)
})
