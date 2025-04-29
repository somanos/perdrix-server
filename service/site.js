const { Entity } = require('@drumee/server-core');
const {
  Attr
} = require('@drumee/server-essentials');

class Site extends Entity {

  /**
   * 
   */
  async create() {
    let args = this.input.get('args');
    let exists = await this.db.await_func('site_exists', args);
    let data;
    if (exists) {
      data = await this.db.await_proc('site_get', exists);
      return this.output.data(data);
    }
    let { postcode, city } = args;
    if (!postcode || !city) {
      this.exception.user("REQUIRE_POSTCODE");
      return
    }
    data = await this.db.await_proc('site_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async list() {
    const custId = this.input.get('custId');
    const siteId = this.input.get('siteId');
    const page = this.input.get(Attr.page);
    const filter = this.input.get('filter');
    let opt = { custId, page, siteId };
    if (filter) opt.filter = filter;
    this.debug("AAA:42", JSON.stringify(opt))
    let data = await this.db.await_proc('site_list', opt);
    this.output.list(data);
  }


}


module.exports = Site;