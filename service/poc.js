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
    this.debug("AAA:12 create", JSON.stringify(args))
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
    let data = await this.db.await_proc('poc_list', opt);
    this.output.list(data);
  }

  /**
   * 
   */
  async search() {
    const page = this.input.get(Attr.page);
    let words = this.input.get('words') || '^.*$';
    let key = this.input.get(Attr.key) || 'lastname';
    if (!/^(\^).+/) {
      words = `^${words}`;
    }
    let data = await this.db.await_proc('poc_search', { key, words, page });
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