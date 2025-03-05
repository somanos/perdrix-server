const { Entity } = require('@drumee/server-core');
const {
  Cache, toArray, Attr, RedisStore, Mariadb
} = require('@drumee/server-essentials');
const { resolve } = require('path');
const Db = new Mariadb({ name: 'perdrix' });

class Perdrix extends Entity {

  /**
   * 
   */
  async list_client() {
    const sort_by = this.input.get(Attr.sort_by) || 'nom';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    let data = await Db.await_proc('client_list', { sort_by, order, page });
    this.debug("AAA:18", data)
    this.output.data(data);
  }


  /**
    * 
  */
  async search() {
    const words = this.input.get('words') || 'nom';
    let tables = this.input.get('tables') || ':all:';
    const page = this.input.get(Attr.page);
    if (!page) page = 1;
    if (/^ch/i.test(tables)) tables = `:chantier:`;
    if (/^cc/i.test(tables)) tables = `:${tables}:contactChantier:`;
    if (/^cl/i.test(tables)) tables = `:${tables}:client:`;
    tables = tables.replace(/:+/, ':');
    let data = await Db.await_proc('seo_search', { tables, words, page });
    this.debug("AAA:18", data, { tables, words, page })
    this.output.list(data);
  }

}


module.exports = Perdrix;