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
    // const custId = this.input.get('custId');
    // const siteId = this.input.get('siteId') || 0;
    // const fiscalYear = this.input.get('fiscalYear');
    // const page = this.input.get(Attr.page);
    // let opt = { page };
    // if (/[0-9]{4,4}/.test(fiscalYear)) {
    //   opt.fiscalYear = fiscalYear;
    // }
    // if (custId) {
    //   opt.custId = custId;
    // }
    // if (siteId) {
    //   opt.siteId = siteId;
    // }
    // let data = await this.db.await_proc('quote_list', opt);
    // this.output.list(data);
  }

  /**
    * 
    */
  balance() {
    return super.balance('quote')
    // const custId = this.input.get('custId') || 0;
    // const siteId = this.input.get('siteId') || 0;
    // const fiscalYear = this.input.get('fiscalYear');
    // let opt = {}
    // if (/[0-9]{4,4}/.test(fiscalYear)) {
    //   opt.fiscalYear = fiscalYear;
    // }
    // if (custId) {
    //   opt.custId = custId;
    // }
    // if (siteId) {
    //   opt.siteId = siteId;
    // }
    // let data = await this.db.await_proc('quote_balance', opt);
    // this.output.data(data);
  }

  /**
  * 
  */
  update() {
    return super.update('quote')
    // const args = this.input.get('args');
    // let data = await this.db.await_proc('quote_update', args);
    // this.output.data(data);
  }
}


module.exports = Quote;