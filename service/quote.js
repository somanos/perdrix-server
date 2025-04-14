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
  async writeTemplate(quote) {
    const tpl_file = 'quotation.xml';
    const Shelljs = require("shelljs");
    const tpl = resolve(__dirname, TPL_BASE, tpl_file);
    let { custId, workId, description } = this.input.get('args');
    let work = await this.db.await_proc('work_get', workId);
    if (!description) description = work.description;
    const {
      custName, housenumber, streettype, streetname, additional, postcode, city
    } = await this.db.await_proc('customer_get', custId);
    let view = {
      date: new Date(new Date().getTime()).toLocaleDateString(this.input.language()),
      custName,
      housenumber,
      streettype,
      streetname,
      description,
      additional,
      postcode,
      city,
      ...quote
    }
    let year = new Date().getFullYear();
    let opt = {
      hub_id: this.hub.get(Attr.id),
      pid: this.home_id,
      ownpath: `/devis/${year}`
    }
    let dir = await this.make_dir(opt);
    if (isEmpty(dir) || !dir.nid) {
      return;
    }

    let tpl_str = readFileSync(tpl);
    tpl_str = String(tpl_str).trim().toString();
    let content = Mustache.render(tpl_str, view);
    let base = this.randomString() + "-quotation";
    const xml_file = resolve(tmp_dir, `${base}.xml`);

    writeFileSync(xml_file, content, { encoding: "utf-8" });
    Shelljs.env["HOME"] = tmp_dir;
    let cmd = `/usr/bin/libreoffice --headless --convert-to docx --outdir ${tmp_dir} ${xml_file}`;
    if (Shelljs.exec(cmd)) {
      let file = resolve(tmp_dir, `${base}.docx`);
      if (!existsSync(file)) {
        return null;
      }
      opt.incoming_file = file;
      const { size } = statSync(file, { throwIfNoEntry: false });
      opt.filesize = size;
      let content = readFileSync(file);
      let hash = createHash("md5");
      let chunk = Buffer.from(content, "utf8");
      hash.update(chunk);
      opt.md5Hash = hash.digest("hex");
      opt.parent = dir;
      opt.filename = `dev${quote.chrono}.docx`;
      opt.filetype = Attr.document
      opt.ownpath = resolve(opt.ownpath, opt.filename);
      opt.pid = dir.nid;
      let data = await this.db.await_proc("mfs_get_by_path", opt.ownpath);
      if (data && data.nid) {
        opt.replace = 1;
        opt.nid = data.nid;
      }
      return opt;
    }
    return null;
  }

  /**
   * 
   */
  async create() {
    let args = this.input.get('args');
    // let work = await this.db.await_proc('work_get', args.workId);
    // let site = await this.db.await_proc('site_get', args.siteId);
    // let customer = await this.db.await_proc('customer_get', args.custId);
    for (let name of ['ht', 'ttc', 'tva', 'discount']) {
      args[name] = args[name] || 0;
    }

    let quote = await this.db.await_proc('quote_create', args);
    if (!quote || !quote.workId || !quote.chrono) {
      this.exception.server("QUOTE_FAILED");
      return
    }
    let data = await this.writeTemplate(quote);
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
    await this.db.await_proc('quote_update', { folderId: node.nid, id: quote.id});
    let work = await this.db.await_proc('work_details', quote.workId);
    this.output.data(work);
  }

  /**
   * 
   */
  async _create() {
    let args = this.input.get('args');
    let { description, category } = args;
    if (!args.siteId) {/** User customer location as site */
      args = await this.db.await_proc('customer_get', args);
      let exists = await this.db.await_func('site_exists', args);
      if (!exists) {
        let { id } = await this.db.await_proc('site_create', args);
        args.siteId = id;
      } else {
        args.siteId = exists;
      }
    }
    args.description = description;
    args.category = category;
    let data = await this.db.await_proc('work_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async list() {
    const custId = this.input.get('custId');
    const page = this.input.get(Attr.page) || 1;
    this.debug("AAA:23", { custId, page })
    let data = await this.db.await_proc('note_list', { custId, page });
    this.debug("AAA:23", data)
    this.output.list(data);
  }

}


module.exports = Quote;