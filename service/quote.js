const { Sales } = require('./lib/sales');
const {
  Attr
} = require('@drumee/server-essentials');

class Quote extends Sales {

  /**
   * 
   */
  async create() {
    let args = this.input.get('args');
    let dest_dir = "/Devis";
    for (let name of ['ht', 'ttc', 'tva', 'discount']) {
      args[name] = args[name] || 0;
    }

    let quote = await this.db.await_proc('quote_create', args);
    if (!quote || !quote.custId || !quote.chrono) {
      this.exception.server("QUOTE_FAILED");
      return
    }
    let customer = await this.db.await_proc('customer_get', quote.custId);
    quote = { ...customer, ...quote };
    let data = await this.writeTemplate(quote, {
      template: "quote.fodt",
      dest_dir,
      prefix: "dev"
    });
    if (!data || !data.incoming_file) {
      this.exception.server("QUOTE_TEMPLATE_FAILED");
      return;
    }
    let node;
    if (data.replace) {
      node = await this.replace(data);
    } else {
      node = await this.store(data)
    }
    await this.db.await_proc('quote_update', { docId: node.nid, id: quote.id });
    let work = await this.db.await_proc('work_details', quote.workId);
    this.output.data(work);
  }

  /**
   * 
   */
  async remove() {
    const quoteId = this.input.get(Attr.id) || 0;
    await this.db.await_proc('quote_remove', quoteId);
    this.output.data({ quoteId });
  }

  /**
   * 
   */
  list() {
    return super.list('quote')
  }

  /**
    * 
    */
  balance() {
    return super.balance('quote')
  }

  /**
  * 
  */
  update() {
    return super.update('quote')
  }
}


module.exports = Quote;