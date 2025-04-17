const { Entity } = require('@drumee/server-core');
const {
  Attr
} = require('@drumee/server-essentials');

class Customer extends Entity {

  /**
   * 
   */
  async list() {
    const sort_by = this.input.get(Attr.sort_by) || 'nom';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    let words = this.input.get('words') || '^.*$';
    this.debug("AAA:16", {page, words})
    let data = await this.db.await_proc('customer_list', { words, sort_by, order, page });
    this.output.list(data);
  }


  /**
   * 
   */
  async create() {
    let args = this.input.get('args')
    this.debug("AAA:26", JSON.stringify(args))
    let data = await this.db.await_proc('customer_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async customer_get() {
    const custId = this.input.get('custId');
    let data = await this.db.await_proc('customer_list', { custId });
    this.output.list(data);
  }



  /**
   * 
   */
  async search() {
    const sort_by = this.input.get(Attr.sort_by) || 'nom';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    const type = this.input.get(Attr.type);
    let words = this.input.get('words') || '^.*$';
    words = `^${words}`;
    let data = await this.db.await_proc('customer_list', { words, sort_by, order, page, type });
    this.debug("AAAA:65", { words, sort_by, order, page })
    console.log("AAA:8888", getUiInfo(), getPluginsInfo())
    this.output.list(data);
  }

}


module.exports = Customer;