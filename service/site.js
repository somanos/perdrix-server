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
    this.debug("AAA:26", exists, JSON.stringify(args))
    if(exists){
      data = await this.db.await_proc('site_get', exists);
      return this.output.data(data);
    }
    data = await this.db.await_proc('site_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async list() {
    const custId = this.input.get('custId');
    const page = this.input.get(Attr.page);
    let data = await this.db.await_proc('site_list', { custId, page });
    this.debug("AAA:42", JSON.stringify({ custId, page, data }))
    this.output.list(data);
  }


}


module.exports = Site;