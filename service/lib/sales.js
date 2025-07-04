const { DrumeeMfs } = require('./mfs');
const { MfsTools } = require("@drumee/server-core");
const { get_node_content } = MfsTools;

const { createHash } = require("crypto");
const { join, resolve } = require("path");
const {
  readFileSync,
  statSync,
  writeFileSync,
  existsSync,
} = require("fs");
const {
  Attr, Cache, sysEnv
} = require("@drumee/server-essentials");
const { tmp_dir } = sysEnv()

const { isEmpty } = require("lodash");

class Sales extends DrumeeMfs {

  /**
   * 
   */
  async createParentDir(base, name = "Odt") {
    let year = new Date().getFullYear();
    let opt = {
      hub_id: this.hub.get(Attr.id),
      pid: this.home_id,
      ownpath: join(base, year.toString(), name)
    }
    let dir = await this.make_dir(opt);
    if (isEmpty(dir) || !dir.nid) {
      return;
    }
    return dir;
  }

  /**
   * 
   * @param {*} file 
   */
  not_fount(file) {
    this.debug("Could not find template file", file)
  }

  /**
 * 
 * @param {*} args 
 * @returns 
 */
  async generate_file(data, args) {
    let { template, prefix, tpl_dir, locale = 'fr' } = args;
    let custom_tpl = Cache.getSysConf('custom_tpl') || '/.ini/templates';
    let nid = await this.db.await_func('node_id_from_path', join(custom_tpl, template));
    this.debug("AAA:56", nid, args)
    let template_file;
    if (nid) {
      let node = await this.db.await_proc('mfs_node_attr', nid);
      template_file = get_node_content(node)
    }
    if (!template_file) {
      if (!tpl_dir) {
        tpl_dir = resolve(__dirname, "../../templates");
      }
      template_file = resolve(tpl_dir, template);
    }

    if (!existsSync(template_file)) {
      return this.not_fount(template_file)
    }

    console.log("AAA:29", { custom_tpl, nid, template, template_file, args }, join(custom_tpl, template));

    let time = new Date().toLocaleString(locale);
    let [day, hour] = time.split(/ +/);

    data.my_city = Cache.getSysConf('perdrix_city');
    data.date = day;
    data.tva_val = data.ttc - data.ht;
    let { site } = data;
    let { location, city, postcode } = site || {};
    if (location) {
      location = location.join(' ');
    }
    data.subject = `${location} ${city} - ${postcode}`.trim();
    data.subject = data.subject.replace(/( *\- *)$/, '');

    const Mustache = require("mustache")
    let template_str = readFileSync(template_file);
    let content = Mustache.render(String(template_str).trim().toString(), data);
    let base = `${prefix}-${this.randomString()}`;
    const xml_out = resolve(tmp_dir, `${base}.xml`);
    writeFileSync(xml_out, content, { encoding: "utf-8" });

    return base;
  }

  /**
   * 
   */
  async writeTemplate(view, args) {
    let { prefix, dest_dir } = args;
    let parent = await this.createParentDir(dest_dir)
    if (isEmpty(parent) || !parent.nid) {
      return this.exception.server("PARENT_DIR_FAILED")
    }

    let filename = await this.generate_file(view, args);
    if (!filename) {
      return this.exception.server("GENERATION_FAILED")
    }
    const Shelljs = require("shelljs");
    Shelljs.env["HOME"] = tmp_dir;
    let ext = "odt";
    let source = resolve(tmp_dir, `${filename}.xml`);
    const cmd = `/usr/bin/libreoffice --headless --convert-to ${ext} --outdir ${tmp_dir} ${source}`;
    this.debug("AAA:", cmd)
    if (Shelljs.exec(cmd)) {
      let file = resolve(tmp_dir, `${filename}.${ext}`);
      if (!existsSync(file)) {
        this.warn("Could not find generated file", file)
        return null;
      }
      let opt = {
        incoming_file: file
      }
      const { size } = statSync(file, { throwIfNoEntry: false });
      opt.filesize = size;
      let content = readFileSync(file);
      let hash = createHash("md5");
      let chunk = Buffer.from(content, "utf8");
      hash.update(chunk);
      opt.md5Hash = hash.digest("hex");
      opt.parent = parent;
      opt.filename = `${prefix}${view.chrono}.${ext}`;
      opt.filetype = Attr.document;
      opt.ownpath = resolve(parent.ownpath, opt.filename);
      opt.pid = parent.nid;
      let res = await this.db.await_proc("mfs_get_by_path", opt.ownpath);
      if (res && res.nid) {
        opt.replace = 1;
        opt.nid = res.nid;
      }
      return opt;
    }
    return null;
  }

  /**
  * 
  */
  async list(type) {
    let args = this.input.get('args');
    if (args.fiscalYear && !/[0-9]{4,4}/.test(args.fiscalYear)) {
      delete args.fiscalYear;
    }

    let data = await this.db.await_proc(`${type}_list`, args);
    this.output.list(data);
  }

  /**
    * 
    */
  async balance(type) {
    const custId = this.input.get('custId') || 0;
    const siteId = this.input.get('siteId') || 0;
    const status = this.input.get(Attr.status);
    const fiscalYear = this.input.get('fiscalYear');
    let opt = {}
    if (/[0-9]{4,4}/.test(fiscalYear)) {
      opt.fiscalYear = fiscalYear;
    }
    if (custId) {
      opt.custId = custId;
    }
    if (status) {
      opt.status = status;
    }
    if (siteId) {
      opt.siteId = siteId;
    }
    let data = await this.db.await_proc(`${type}_balance`, opt);
    this.output.data(data);
  }

  /**
  * 
  */
  async update(type) {
    const args = this.input.get('args');
    let data = await this.db.await_proc(`${type}_update`, args);
    this.output.data(data);
  }
}


module.exports = { Sales };