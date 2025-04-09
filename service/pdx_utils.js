const { Entity } = require('@drumee/server-core');
const {
  Cache, Attr, Network
} = require('@drumee/server-essentials');

class PerdrixUtils extends Entity {

  /**
    * 
    */
  async get_env() {
    let data = {};
    data.hub_id = await this.yp.await_func('get_sysconf', 'perdrix-hub');
    data.app_home = await this.yp.await_func('get_sysconf', 'app_host');
    data.map_tiler_api_key = await this.yp.await_func('get_sysconf', 'map-tiler-api-key');
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
      data.pocRoles = await this.db.await_query(
        'SELECT DISTINCT role label, role FROM poc'
      );
    }
    this.output.data(data);
  }

  /**
    * 
    */
  async get_geoloc() {
    let l = this.input.get(Attr.location) || [];
    let postcode = this.input.get('postcode');
    let id = this.input.get(Attr.id);
    let type = this.input.get(Attr.type);
    if (!l.length || !postcode || postcode.length < 5) {
      return this.output.data({});
    }
    let words = l.join('+');
    words = words.replace(/ +/g, '+');
    let api_endpoint = Cache.getSysConf('address_api_endpoint');
    let url = api_endpoint.format(words) + `&postcode=${postcode}`;
    this.debug("AAA:54", { words, type, id })
    Network.request(url).then(async (data) => {
      let { features } = data || {};
      let res = features[0];
      this.debug("AAA:51", features);
      if (res && res.geometry) {
        await this.db.await_proc('update_geo', id, type, res.geometry)
      }
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
    let tables = this.input.get('tables');
    const page = this.input.get(Attr.page);
    if (!page) page = 1;
    let data;
    if (/^[0-9]+$/.test(words)) {
      this.debug("AAA:101 waiting for", { words })
      data = await this.db.await_proc('search_by_id', { words, page }, tables);
      this.output.list(data);
      this.debug("AAA:105 Got", { words })

      return
    }

    if (/^.+[\.!]$/.test(words)) {
      words = words.replace(/[\.!]$/, '');
    } else {
      if (!/^.+\*$/.test(words)) words = words + "*";
    }
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