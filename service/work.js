const { Entity } = require('@drumee/server-core');

const {
  Attr, nullValue
} = require('@drumee/server-essentials');

class Work extends Entity {


  /**
   * 
   */
  async create() {
    let args = this.input.get('args');
    let { description, category, custId } = args;
    if (!args.siteId) {/** User customer location as site */
      args = await this.db.await_proc('customer_get', custId);
      if (!args || !args.custId) {
        return this.exception.user("INVALID_CUSTID")
      }
      let exists = await this.db.await_func('site_exists', args);
      if (!exists) {
        let { id } = await this.db.await_proc('site_create', args);
        args.siteId = id;
      } else {
        args.siteId = exists;
      }
    }
    args.description = description;
    args.category = category;
    let data = await this.db.await_proc('work_create', args);

    this.output.data(data);
  }

  /**
  * 
  */
  async list() {
    // const custId = this.input.get('custId');
    // const siteId = this.input.get('siteId');
    // const addressId = this.input.get('addressId');
    // const filter = this.input.get('filter');
    // const status = this.input.get(Attr.status);
    // const page = this.input.get(Attr.page);
    // let opt = { custId, page, status };
    // if (filter) opt.filter = filter;
    // if (!nullValue(siteId)) {
    //   opt.siteId = siteId;
    // }
    // if (!nullValue(addressId)) {
    //   opt.addressId = addressId;
    // }
    let args = this.input.get('args');
    this.debug("AAA:54", JSON.stringify(args))
    let data = await this.db.await_proc('work_list', args);
    this.output.list(data);
  }

  /**
  * 
  */
  async summary() {
    const workId = this.input.get('workId');
    let data = await this.db.await_proc('work_get', workId);
    this.output.data(data);
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
    let data = await this.db.await_proc('work_search',
      { words, sort_by, order, page, custId });
    this.output.list(data);
  }

  /**
  * 
  */
  async bills() {
    const workId = this.input.get('workId');
    const page = this.input.get(Attr.page) || 1;
    let data = await this.db.await_proc('work_bills', { workId, page, uid: this.uid });
    this.output.list(data);
  }

  /**
  * 
  */
  async notes() {
    const workId = this.input.get('workId');
    const page = this.input.get(Attr.page) || 1;
    let data = await this.db.await_proc('work_notes', { workId, page, uid: this.uid });
    this.output.list(data);
  }

  /**
  * 
  */
  async update() {
    let args = this.input.get('args');
    let data = await this.db.await_proc('work_update', args);
    this.output.data(data);
  }

  /**
  * 
  */
  async quotes() {
    const workId = this.input.get('workId');
    const page = this.input.get(Attr.page) || 1;
    let data = await this.db.await_proc('work_quotes', { workId, page, uid: this.uid });
    this.output.list(data);
  }

}


module.exports = Work;