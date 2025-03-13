const { Entity } = require('@drumee/server-core');
const {
  Cache, Attr, Mariadb, Network, toArray
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
    let words = this.input.get('words') || '^.*$';
    let data = await Db.await_proc('customer_list', { words, sort_by, order, page });
    this.debug("AAAA:19", { words, sort_by, order, page })
    this.output.list(data);
  }

  /**
   * 
   */
  async customer_search() {
    const sort_by = this.input.get(Attr.sort_by) || 'nom';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    const type = this.input.get(Attr.type);
    let words = this.input.get('words') || '^.*$';
    words = `^${words}`;
    let data = await Db.await_proc('customer_list', { words, sort_by, order, page, type });
    this.debug("AAAA:19", { words, sort_by, order, page })
    this.output.list(data);
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
    this.output.list(data);
  }

  /**
    * 
  */
  async search_location() {
    let words = this.input.get('words') || 'nom';
    words = words.replace(/ +/g, '+');
    let api_endpoint = Cache.getSysConf('address_api_endpoint');
    let url = api_endpoint.format(words)
    Network.request(url).then((data)=>{
      let { features } = data || {};
      this.debug("AAA:37", { words, api_endpoint}, features)
      this.output.list(features);
    }).catch((e)=>{
      this.warn("Failed to get data from ", { words, api_endpoint}, e)
      this.output.list([]);
  
    });
  }

}


module.exports = Perdrix;