const { Entity } = require('@drumee/server-core');

class Perdrix extends Entity {

  /**
   * 
   */
  async createWork() {
    let args = this.input.get('args');
    let { description, category } = args;
    if (!args.siteId) {/** User customer location as site */
      args = await this.db.await_proc('customer_get', args);
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
}
module.export = { Perdrix }