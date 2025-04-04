const { Entity } = require('@drumee/server-core');
const { getPluginsInfo, getUiInfo } = require('@drumee/server-essentials');
const {
  Cache, Attr, Mariadb, Network
} = require('@drumee/server-essentials');

class Perdrix extends Entity {


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