const { Entity } = require('@drumee/server-core');
const {
  Cache, Attr, Mariadb, Network
} = require('@drumee/server-essentials');
const { resolve } = require('path');
const Db = new Mariadb({ name: 'perdrix' });

class Perdrix extends Entity {

  /**
   * 
   */
  async customer_list() {
    const sort_by = this.input.get(Attr.sort_by) || 'nom';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    let words = this.input.get('words') || '.++';
    let data = await Db.await_proc('customer_list', { words, sort_by, order, page });
    this.output.data(data);
  }


  /**
    * 
  */
  async search() {
    let words = this.input.get('words') || 'nom';
    let tables = this.input.get('tables');
    const page = this.input.get(Attr.page);
    if (!page) page = 1;
    if (/^.+[\.!]$/.test(words)) {
      words = words.replace(/[\.!]$/, '');
    } else {
      if (!/^.+\*$/.test(words)) words = words + "*";
    }
    let data = await Db.await_proc('seo_search', { words, page }, tables);
    this.debug("AAA:37", { words, page }, tables)
    this.output.list(data);
  }

  /**
    * 
  */
  async search_address() {
    let words = this.input.get('words') || 'nom';
    words = words.replace(/ +/g, '+');
    let api_endpoint = Cache.getSysConf('address_api_endpoint');
    let url = api_endpoint.format(words)
    let data = await Network.request(url);
    this.output.list(data);
  }

}


module.exports = Perdrix;