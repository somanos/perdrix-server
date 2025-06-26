
const { exit, env } = process;
const { basename, extname, resolve } = require('path');

const {

  inject,
  
} = require('./parser')
const args = require("./args");

let src;

if (/^\//.test(args.source)) {
  src = args.source;
} else {
  src = resolve(__dirname, args.source);
}

let skip = []
if (args.skip) {
  skip = args.skip.split(/[,; ]/)
}

/**
 * 
 */
inject(src, skip).then(async (rows) => {
  setTimeout(() => {
    exit();
  }, 500)
})
