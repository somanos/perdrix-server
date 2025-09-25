const { Entity } = require('@drumee/server-core');

const {
  parse_location, get_geoloc, search_with_address, search_in_table, _search_location, search_location, search, fiscal_years
} = require("./lib/utils")

class PerdrixUtils extends Entity {

  constructor(...args) {
    super(...args);
    this.fiscal_years = fiscal_years.bind(this);
    this.parse_location = parse_location.bind(this);
    this.get_geoloc = get_geoloc.bind(this);
    this.search_with_address = search_with_address.bind(this);
    this.search_in_table = search_in_table.bind(this);
    this._search_location = _search_location.bind(this);
    this.search_location = search_location.bind(this);
    this.search = search.bind(this);
  }
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
}


module.exports = PerdrixUtils;