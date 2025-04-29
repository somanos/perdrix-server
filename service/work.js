const { Entity } = require('@drumee/server-core');

const {
  Attr, nullValue
} = require('@drumee/server-essentials');

class Work extends Entity {

  /**
   * 
   * @returns 
   */
  // async createWork() {
  //   let args = this.input.get('args');
  //   let { description, category, custId} = args;
  //   if (!args.siteId) {/** User customer location as site */
  //     args = await this.db.await_proc('customer_get', custId);
  //     this.debug("AAA:18", args)
  //     if(!args || !args.custId){
  //       return this.exception.user("INVALID_CUSTID")
  //     }
  //     let exists = await this.db.await_func('site_exists', args);
  //     if (!exists) {
  //       let { id } = await this.db.await_proc('site_create', args);
  //       args.siteId = id;
  //     } else {
  //       args.siteId = exists;
  //     }
  //   }
  //   args.description = description;
  //   args.category = category;
  //   let data = await this.db.await_proc('work_create', args);
  //   return data
  // }

  /**
   * 
   */
  async create() {
    let args = this.input.get('args');
    let { description, category, custId } = args;
    if (!args.siteId) {/** User customer location as site */
      args = await this.db.await_proc('customer_get', custId);
      this.debug("AAA:18", args)
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
    const custId = this.input.get('custId');
    const siteId = this.input.get('siteId');
    const filter = this.input.get('filter');
    const status = this.input.get(Attr.status);
    const page = this.input.get(Attr.page);
    let opt = { custId, page, status };
    if (filter) opt.filter = filter;
    if (!nullValue(siteId)) {
      opt.siteId = siteId;
    }
    let data = await this.db.await_proc('work_list', opt);
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
  async bills() {
    const workId = this.input.get('workId');
    const page = this.input.get(Attr.page) || 1;
    let data = await this.db.await_proc('work_bills', { workId, page });
    this.output.list(data);
  }

  /**
  * 
  */
  async notes() {
    const workId = this.input.get('workId');
    const page = this.input.get(Attr.page) || 1;
    let data = await this.db.await_proc('work_notes', { workId, page });
    this.output.list(data);
  }

  /**
  * 
  */
  async quotations() {
    const workId = this.input.get('workId');
    const page = this.input.get(Attr.page) || 1;
    let data = await this.db.await_proc('work_quotations', { workId, page });
    this.output.list(data);
  }

}


module.exports = Work;