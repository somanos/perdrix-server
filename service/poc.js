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
  async create_poc() {
    let args = this.input.get('args')
    let data = await this.db.await_proc('costumer_poc_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async list() {
    // const custId = this.input.get('custId');
    // const siteId = this.input.get('siteId');
    // const page = this.input.get(Attr.page) || 1;
    // const filter = this.input.get('filter');
    // let opt = { custId, page };
    // if (filter) opt.filter = filter;
    let page = this.input.get(Attr.page)
    let args = this.input.get('args')
    this.debug("AAA:36 list", JSON.stringify({ page, ...args }))
    let data = await this.db.await_proc('poc_list', { page, ...args });
    this.output.list(data);
  }

  /**
   * 
   */
  async search() {
    const page = this.input.get(Attr.page);
    let words = this.input.get('words');
    this.debug("AAA:47 list", JSON.stringify({ lastname: words, page }))
    let data = await this.db.await_proc('poc_list', { lastname: words, page });
    this.debug("AAA:49 list", JSON.stringify({ lastname: words, page }))
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