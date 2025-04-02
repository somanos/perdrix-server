const { Entity } = require('@drumee/server-core');
const { getPluginsInfo, getUiInfo } = require('@drumee/server-essentials');
const {
  Cache, Attr, Mariadb, Network
} = require('@drumee/server-essentials');

class Perdrix extends Entity {

  /**
   * 
   */
  async customer_list() {
    const sort_by = this.input.get(Attr.sort_by) || 'nom';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    let words = this.input.get('words') || '^.*$';
    let data = await this.db.await_proc('customer_list', { words, sort_by, order, page });
    this.output.list(data);
  }

  /**
   * 
   */
  async work_list() {
    const custId = this.input.get('custId');
    const siteId = this.input.get('siteId');
    const status = this.input.get(Attr.status);
    const page = this.input.get(Attr.page);
    let data = await this.db.await_proc('work_list', { custId, siteId, page, status });
    this.debug("AAA:31", JSON.stringify({ custId, page, data }))
    this.output.list(data);
  }

  /**
   * 
   */
  async site_list() {
    const custId = this.input.get('custId');
    const page = this.input.get(Attr.page);
    let data = await this.db.await_proc('site_list', { custId, page });
    this.debug("AAA:42", JSON.stringify({ custId, page, data }))
    this.output.list(data);
  }

  /**
   * 
   */
  async customer_create() {
    let args = this.input.get('args')
    this.debug("AAA:26", JSON.stringify(args))
    let data = await this.db.await_proc('customer_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async site_create() {
    let args = this.input.get('args')
    this.debug("AAA:26", JSON.stringify(args))
    let data = await this.db.await_proc('site_create', args);
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
    let data = await this.db.await_proc('customer_list', { words, sort_by, order, page, type });
    this.debug("AAAA:65", { words, sort_by, order, page })
    console.log("AAA:8888", getUiInfo(), getPluginsInfo())
    this.output.list(data);
  }

  /**
   * 
   */
  async customer_get() {
    const custId = this.input.get('custId');
    let data = await this.db.await_proc('customer_list', { custId });
    this.output.list(data);
  }

  /**
   * 
   */
  async poc_list() {
    const custId = this.input.get('custId');
    let data = await this.db.await_proc('poc_list', { custId });
    this.output.list(data);
  }

  /**
   * 
   */
  async poc_create() {
    const custId = this.input.get('custId');
    let args = this.input.get('args')
    this.debug("AAA:26", JSON.stringify(args))
    let data = await this.db.await_proc('poc_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async poc_sites() {
    const custId = this.input.get('custId');
    const id = this.input.get(Attr.id);
    let data = await this.db.await_proc('poc_sites', { custId, id });
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
    let data = await this.db.await_proc('seo_search', { words, page }, tables);
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
      let r = features.map((e) => {
        e.id = e.properties.id;
        return e;
      })
      //this.debug("AAA:143", features)
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
    data.genderList = await this.db.await_query(
      "SELECT shortTag label, id, longTag FROM gender"
    );
    data.streetType = await this.db.await_query(
      "SELECT shortTag label, id, longTag FROM streetType"
    );
    data.countryCode = await this.db.await_query(
      "SELECT code label, id, code countrycode, indicatif FROM country"
    );
    data.companyClass = await this.db.await_query(
      "SELECT tag label, id FROM companyClass"
    );
    data.workType = await this.db.await_query(
      "SELECT tag label, id FROM workType"
    );
    data.hub_id = await this.yp.await_func('get_sysconf', 'perdrix-hub');
    data.map_tiler_api_key = await this.yp.await_func('get_sysconf', 'map-tiler-api-key');
    this.output.data(data);
  }

}


module.exports = Perdrix;