const { Entity } = require('@drumee/server-core');
const {
  Attr
} = require('@drumee/server-essentials');

class Customer extends Entity {

  /**
   * 
   */
  async list() {
    // const sort_by = this.input.get(Attr.sort_by) || 'nom';
    // const order = this.input.get(Attr.order) || 'asc';
    // const page = this.input.get(Attr.page);
    // let words = this.input.get('words') || '^.*$';
    let args = this.input.get('args');
    this.debug('AAA:49', JSON.stringify(args));
    let data = await this.db.await_proc('customer_list', args);
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
  async customer_update() {
    let args = this.input.get('args');
    let id = args.id || args.custId
    if (!id) {
      return this.exception.user('MISSING_ID')
    }
    let data = await this.db.await_proc('customer_create', args);
    this.output.list(data);
  }


  /**
  * 
  */
  async get_pocs_by_addr() {
    let location = this.input.get(Attr.location);
    let postcode = this.input.get('postcode');
    let city = this.input.get(Attr.city);
    this.debug('AAA:49', JSON.stringify({ location, postcode, city }))
    let data = await this.db.await_proc('get_customer_pocs_by_addr',
      { location, postcode, city });
    this.output.list(data);
  }


  /**
   * 
   */
  async search() {
    const sort_by = this.input.get(Attr.sort_by) || 'name';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    const type = this.input.get(Attr.type);
    let words = this.input.get('words') || '^.*$';
    words = `^${words}`;
    let data = await this.db.await_proc('customer_list', { words, sort_by, order, page, type });
    this.output.list(data);
  }

}


module.exports = Customer;