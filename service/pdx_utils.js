const { Entity } = require('@drumee/server-core');
const {
  Cache, Attr, Network
} = require('@drumee/server-essentials');

class PerdrixUtils extends Entity {

  /**
   * 
   */
  async fiscal_years() {
    let sql = `
      SELECT fiscalYear name, fiscalYear content FROM bill GROUP BY fiscalYear 
      ORDER BY fiscalYear DESC
    `;
    let data = await this.db.await_query(sql);
    this.output.list(data);
  }



  /**
    * 
    */
  async get_env() {
    let data = {};
    let { privilege } = await this.db.await_proc("mfs_access_node", this.uid, this.home_id) || {}

    data.hub_id = await this.yp.await_func('get_sysconf', 'perdrix-hub');
    data.app_home = await this.yp.await_func('get_sysconf', 'app_host');
    data.map_tiler_api_key = await this.yp.await_func('get_sysconf', 'map-tiler-api-key');
    let id = await this.db.await_func('node_id_from_path', '/devis');
    if (id) {
      data.quote_home = await this.db.await_proc("mfs_access_node", this.uid, id);
    }
    id = await this.db.await_func('node_id_from_path', '/factures');
    if (id) {
      data.bill_home = await this.db.await_proc("mfs_access_node", this.uid, id);
    }
    if (this.input.host() == data.app_home) {
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
      data.billType = await this.db.await_query(
        "SELECT tag label, id FROM billType"
      );
      data.pocRoles = await this.db.await_query(
        'SELECT DISTINCT role label, role FROM poc'
      );
      data.customerPocRoles = await this.db.await_query(
        'SELECT DISTINCT role label, role FROM customerPoc'
      );
      data.privilege = privilege;
    }
    this.output.data(data);
  }

  /**
    * 
    */
  async get_geoloc() {
    let l = this.input.get(Attr.location) || [];
    let postcode = this.input.get('postcode');

    if (!l.length || !postcode || postcode.length < 5) {
      return this.output.data({});
    }
    if (l[0]) {
      l[0] = l[0].replace(/[\-\/][0-9]+$/, '');
    }
    let words = l.join('+');
    words = words.replace(/ +/g, '+');
    let api_endpoint = Cache.getSysConf('address_api_endpoint');
    let url = api_endpoint.format(words) + `&postcode=${postcode}`;
    Network.request(url).then(async (data) => {
      let { features } = data || {};
      let res = features[0];
      if (res && res.geometry) {
        let addressId = this.input.get("addressId");
        if (addressId) {
          let { geometry } = await this.db.await_proc("address_get", addressId)
          if (!geometry || geometry.type) {
            await this.db.await_proc('update_geo', addressId, res.geometry)
          }
        }
      }
      this.debug("AAA:100", res)
      this.output.data(res);
    }).catch((e) => {
      this.warn("Failed to get data from ", { words, url }, e)
      this.output.data({});
    });
  }


  /**
    * 
  */
  async search() {
    let words = this.input.get('words') || 'nom';
    let tables = this.input.get('tables') || [];
    const page = this.input.get(Attr.page);
    if (!page) page = 1;
    let search_by_id = 0;
    let data;
    let opt;

    if (/^[0-9]+([ ,])+[A-Z]+.+$/i.test(words)) {
      opt = { words, page }
      data = await this.db.await_proc('search_by_address', opt);
      this.output.list(data);
      return
    }

    if (/^[0-9]+(\.)*[0-9]*.+$/i.test(words)) {
      if (/^[0-9]{2,2}\.[0-9]{1,4}[A-Z]{1,1}$/i.test(words)) {
        tables = ['quote'];
      } else if (/^[0-9]{2,2}\..+$/i.test(words)) {
        tables = ['bill', 'quote'];
      } else {
        tables = ['customer', 'poc', 'site', 'work'];
        words = words.replace(/\./g, '');
        words = words + ".*$"
      }
      search_by_id = 1;
    }
    if (search_by_id) {
      let [fiscalYear, serial = ""] = words.split('.');
      this.debug("AAA:124 seo_search", { fiscalYear, serial })
      opt = { fiscalYear, words, page }
      let a = serial.split('');
      if (/[A-Z]{1,1}/i.test(a[a.length - 1])) {
        opt.version = a.pop();
        opt.serial = a.join('');
      } else {
        opt.serial = serial;
      }
      if (tables.includes('quote')) {
        opt.serial = opt.serial.replace(/^[\^0]+/, '');
        opt.serial = `^${opt.serial}`
      }
      this.debug("AAA:135 seo_search", JSON.stringify(opt), JSON.stringify(tables))
      data = await this.db.await_proc('search_by_id', opt, tables);
      this.output.list(data);
      return
    }


    if (/^.+[\.!]$/.test(words)) {
      words = words.replace(/[\.!]$/, '');
    } else {
      if (!/^.+\*$/.test(words)) words = words + "*";
    }
    this.debug("AAA:147 seo_search", JSON.stringify({ words, page }), JSON.stringify(tables))
    data = await this.db.await_proc('seo_search', { words, page }, tables);
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

}


module.exports = PerdrixUtils;