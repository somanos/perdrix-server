const { DrumeeMfs } = require('./lib/mfs');
const {
  Attr, sysEnv,
} = require('@drumee/server-essentials');
const { resolve } = require("path");
const { readFileSync, writeFileSync, statSync, existsSync } = require("fs");
const Mustache = require("mustache")
const TPL_BASE = "../templates";
const { createHash } = require("crypto");
const { isEmpty } = require("lodash");
const { tmp_dir } = sysEnv();

class Quote extends DrumeeMfs {


  /**
   * 
   */
  async create() {
    let args = this.input.get('args');
    for (let name of ['ht', 'ttc', 'tva', 'discount']) {
      args[name] = args[name] || 0;
    }

    let quote = await this.db.await_proc('quote_create', args);
    if (!quote || !quote.workId || !quote.chrono) {
      this.exception.server("QUOTE_FAILED");
      return
    }
    let data = await this.writeTemplate(quote, { tpl_file: "quotation", dest_dir: "/Devis", prefix: "dev" });
    if (!data || !data.incoming_file) {
      this.exception.server("QUOTE_TEMPLATE_FAILED");
      return;
    }
    let node;
    if (data.replace) {
      node = await this.replace(data);
    } else {
      node = await this.store(data)
    }
    await this.db.await_proc('quote_update', { docId: node.nid, id: quote.id });
    let work = await this.db.await_proc('work_details', quote.workId);
    this.output.data(work);
  }


}


module.exports = Quote;