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
    let args = this.input.get('args')
    let data = await this.db.await_proc('note_list', args);
    this.output.list(data);
  }

  /**
  * 
  */
  async remove() {
    const noteId = this.input.get(Attr.id) || 0;
    await this.db.await_proc('note_remove', noteId);
    this.output.data({ noteId });
  }

  /**
   * 
   */
  async update() {
    const args = this.input.get('args');
    this.debug("AAA:144", JSON.stringify(args));
    let data = await this.db.await_proc('note_update', args);
    this.output.data(data);
  }
}


module.exports = Poc;