const { Entity } = require('@drumee/server-core');
const {
  Cache, Attr, Mariadb, Network, toArray
} = require('@drumee/server-essentials');
const { resolve } = require('path');
const Db = new Mariadb({ name: 'perdrix' });

class Perdrix extends Entity {

  /**
   * 
   */
  async customer_list() {
    const sort_by = this.input.get(Attr.sort_by) || 'nom';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    let words = this.input.get('words') || '^.*$';
    let data = await Db.await_proc('customer_list', { words, sort_by, order, page });
    this.output.list(data);
  }

  /**
   * 
   */
  async work_list() {
    const custId = this.input.get('custId');
    const siteId = this.input.get('siteId');
    const page = this.input.get(Attr.page);
    this.debug("AAA:26", JSON.stringify({ custId, siteId, page }))
    let data = await Db.await_proc('work_list', { custId, siteId, page });
    this.output.list(data);
  }

  /**
   * 
   */
  async customer_create() {
    let data = this.input.get('args')
    this.debug("AAA:26", JSON.stringify(data))
    this.output.data(data);
  }

  /**
   * 
   */
  async customer_search() {
    const sort_by = this.input.get(Attr.sort_by) || 'nom';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    const type = this.input.get(Attr.type);
    let words = this.input.get('words') || '^.*$';
    words = `^${words}`;
    let data = await Db.await_proc('customer_list', { words, sort_by, order, page, type });
    this.debug("AAAA:19", { words, sort_by, order, page })
    this.output.list(data);
  }

  /**
   * 
   */
  async customer_get() {
    const custId = this.input.get('custId');
    let data = await Db.await_proc('customer_list', { custId });
    this.output.list(data);
  }


  /**
    * 
  */
  async search() {
    let words = this.input.get('words') || 'nom';
    let tables = this.input.get('tables');
    const page = this.input.get(Attr.page);
    if (!page) page = 1;
    if (/^.+[\.!]$/.test(words)) {
      words = words.replace(/[\.!]$/, '');
    } else {
      if (!/^.+\*$/.test(words)) words = words + "*";
    }
    let data = await Db.await_proc('seo_search', { words, page }, tables);
    this.debug("AAAA:19", { words, tables, page, data })

    this.output.list(data);
  }

  /**
    * 
  */
  async search_location() {
    let words = this.input.get('words') || 'nom';
    words = words.replace(/ +/g, '+');
    let api_endpoint = Cache.getSysConf('address_api_endpoint');
    let url = api_endpoint.format(words)
    this.debug("AAA:63 waiting for", { words, url })
    Network.request(url).then((data) => {
      let { features } = data || {};
      this.debug("AAA:67 received", features, { words, url })
      this.output.list(features);
    }).catch((e) => {
      this.warn("Failed to get data from ", { words, url }, e)
      this.output.list([]);
    });
  }

  /**
    * 
  */
  async get_env() {
    let data = {};
    data.genderList = await Db.await_query(
      "SELECT shortTag label, id, longTag FROM gender"
    );
    data.streetType = await Db.await_query(
      "SELECT shortTag label, id, longTag FROM streetType"
    );
    data.countryCode = await Db.await_query(
      "SELECT code label, id, code countrycode, indicatif FROM country"
    );
    data.companyClass = await Db.await_query(
      "SELECT tag label, id FROM companyClass"
    );
    data.workType = await Db.await_query(
      "SELECT tag label, id FROM workType"
    );
    this.output.data(data);
  }

}


module.exports = Perdrix;