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
    data.pocRoles = await this.db.await_query(
      'SELECT DISTINCT role label, role FROM poc'
    );
    data.map_tiler_api_key = await this.yp.await_func('get_sysconf', 'map-tiler-api-key');
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
    if (!l.length || !postcode) {
      return this.output.data({});
    }
    let words = l.join('+');
    let api_endpoint = Cache.getSysConf('address_api_endpoint');
    let url = api_endpoint.format(words) + `&postcode=${postcode}`;
    this.debug("AAA:48", { type, id })
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
}


module.exports = PerdrixUtils;