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
    let note = await this.db.await_proc('note_create', args);
    let work = await this.db.await_proc('work_details', note.workId);
    this.output.data(work);
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