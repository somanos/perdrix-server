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
    this.debug("AAA:12", JSON.stringify(args))
    let data = await this.db.await_proc('note_create', args);
    this.output.data(data);
  }

  /**
   * 
   */
  async list() {
    const custId = this.input.get('custId');
    const page = this.input.get(Attr.page) || 1;
    let data = await this.db.await_proc('note_list', { custId, page });
    this.output.list(data);
  }

}


module.exports = Poc;