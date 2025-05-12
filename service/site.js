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
  async list_poc() {
    const siteId = this.input.get('siteId');
    const page = this.input.get(Attr.page) || 1;
    let opt = { siteId, page };
    let data = await this.db.await_proc('site_list_poc', opt);
    this.output.list(data);
  }

  /**
   * 
   */
  async add_poc() {
    let args = this.input.get('args');
    let data;
    if (args.pocId && args.custId && args.siteId) {
      if (args.lastname) {
        data = await this.db.await_proc('poc_update', args);
      }
      data = await this.db.await_proc('site_add_poc', args);
    } else {
      let { pocId, custId, siteId } = await this.db.await_proc('poc_create', args);
      if (pocId) {
        data = await this.db.await_proc('site_add_poc', { pocId, custId, siteId });
      }
    }
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
    let data = await this.db.await_proc('site_list', opt);
    this.output.list(data);
  }

  /**
   * 
   */
  async search() {
    const sort_by = this.input.get(Attr.sort_by) || 'name';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    const custId = this.input.get('custId');
    let words = this.input.get('words') || '^.*$';
    if (words !== '^.*$') {
      words = `(?i)${words}`
    }
    this.debug("AAA:18", { words, sort_by, order, page, custId })

    let data = await this.db.await_proc('site_search',
      { words, sort_by, order, page, custId });
    this.output.list(data);
  }


}


module.exports = Site;