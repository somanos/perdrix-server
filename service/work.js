const { Entity } = require('@drumee/server-core');

const {
  Attr
} = require('@drumee/server-essentials');

class Work extends Entity {

  /**
   * 
   * @returns 
   */
  async createWork() {
    let args = this.input.get('args');
    let { description, category, custId} = args;
    if (!args.siteId) {/** User customer location as site */
      args = await this.db.await_proc('customer_get', custId);
      this.debug("AAA:18", args)
      if(!args || !args.custId){
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
    return data
  }
  
  /**
   * 
   */
  async create() {
    let data = await this.createWork();
    this.output.data(data);
  }

  /**
  * 
  */
  async list() {
    const custId = this.input.get('custId');
    const siteId = this.input.get('siteId');
    const status = this.input.get(Attr.status);
    const page = this.input.get(Attr.page);
    this.debug("AAA:52", JSON.stringify({ custId, siteId, page, status }))
    let data = await this.db.await_proc('work_list', { custId, siteId, page, status });
    this.output.list(data);
  }
}


module.exports = Work;