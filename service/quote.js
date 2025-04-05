const { Entity } = require('@drumee/server-core');
const {
  Attr
} = require('@drumee/server-essentials');
const { resolve } = require("path");
const { readFileSync, writeFileSync} = require("fs");
const Mustache = require("mustache")
const TPL_BASE = "../templates";

class Quote extends Entity {

  /**
 *libreoffice --headless --convert-to odt your-document.xml
 */
  async writeTemplate(filename) {
    const tpl = resolve(__dirname, TPL_BASE, filename);
    const custId = this.input.need('custId');
    const siteId = this.input.need('siteId');
    const description = this.input.get('description') || "Bla bla";
    const { 
      custName, housenumber, streettype,  streetname, additional, postcode , city
    } = await this.db.await_proc('customer_get', custId);
    const site = await this.db.await_proc('site_get', siteId);
    let view = {
      date: new Date(new Date().getTime()).toLocaleDateString(this.input.language()),
      custName,
      housenumber,
      streettype,
      streetname,
      description,
      quoteId:9999,
      additional,
      postcode , 
      city
    }
    let tpl_str = readFileSync(tpl);
    tpl_str = String(tpl_str).trim().toString();
    let content = Mustache.render(tpl_str, view);
    this.debug("AAA:23", { tpl, view, site,  content})
    writeFileSync('/data/tmp/quotation.xml', content, { encoding: "utf-8" });

    return tpl;
  }

  /**
   * 
   */
  async create() {
    let args = this.input.get('args')
    let path = await this.writeTemplate('quotation.xml')
    this.output.data({ path });
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