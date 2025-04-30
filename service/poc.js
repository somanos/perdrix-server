const { Entity } = require('@drumee/server-core');
const {
  Attr
} = require('@drumee/server-essentials');

class Poc extends Entity {
  /**
   * 
   */
  async create() {
    let args = this.input.get('args')
    let data = await this.db.await_proc('poc_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async list() {
    const custId = this.input.get('custId');
    const siteId = this.input.get('siteId');
    const page = this.input.get(Attr.page) || 1;
    let opt = { custId, page };
    if (siteId) opt.siteId = siteId
    this.debug("AAA:23", opt)
    let data = await this.db.await_proc('poc_list', opt);
    this.debug("AAA:23", data)
    this.output.list(data);
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

}


module.exports = Poc;