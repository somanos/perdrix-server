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

class Bill extends DrumeeMfs {

  /**
   * 
   */
  async writeTemplate(bill) {
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
      ...bill
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
      opt.filename = `dev${bill.chrono}.docx`;
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
  async __create() {
    let args = this.input.get('args');
    for (let name of ['ht', 'ttc', 'tva', 'discount']) {
      args[name] = args[name] || 0;
    }

    let bill = await this.db.await_proc('bill_create', args);
    if (!bill || !bill.workId || !bill.chrono) {
      this.exception.server("BILL_FAILED");
      return
    }
    let data = await this.writeTemplate(bill);
    if (!data || !data.incoming_file) {
      this.exception.server("BILL_TEMPLATE_FAILED");
      return;
    }
    let node;
    if (data.replace) {
      node = await this.replace(data);
    } else {
      node = await this.store(data)
    }
    await this.db.await_proc('bill_update', { docId: node.nid, id: bill.id });
    let work = await this.db.await_proc('work_details', bill.workId);
    this.output.data(work);
  }

  /**
  * 
  */
  async create() {
    let args = this.input.get('args');
    for (let name of ['ht', 'ttc', 'tva']) {
      args[name] = args[name] || 0;
    }

    let bill = await this.db.await_proc('bill_create', args);
    if (!bill || !bill.workId || !bill.chrono) {
      this.exception.server("BILL_FAILED");
      return
    }
    let data = await this.writeTemplate(bill, { tpl_file: "bill", dest_dir: "/Factures", prefix: "fac" });
    if (!data || !data.incoming_file) {
      this.exception.server("BILL_TEMPLATE_FAILED");
      return;
    }
    let node;
    if (data.replace) {
      node = await this.replace(data);
    } else {
      node = await this.store(data)
    }
    await this.db.await_proc('bill_update', { docId: node.nid, id: bill.id });
    let work = await this.db.await_proc('work_details', bill.workId);
    this.output.data(work);
  }

  /**
   * 
   */
  async list() {
    const custId = this.input.get('custId');
    const status = this.input.get(Attr.status);
    const page = this.input.get(Attr.page);
    this.debug("AAA:126", JSON.stringify({ custId, page, status }))
    let data = await this.db.await_proc('bill_list', { custId, page, status });
    this.output.list(data);
  }

}


module.exports = Bill;