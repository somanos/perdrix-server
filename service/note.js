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
    let data = await this.db.await_proc('note_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async list() {
    const custId = this.input.get('custId');
    const page = this.input.get(Attr.page) || 1;
    this.debug("AAA:23",  { custId, page })
    let data = await this.db.await_proc('note_list', { custId, page });
    this.debug("AAA:23",  data)
    this.output.list(data);
  }

}


module.exports = Poc;