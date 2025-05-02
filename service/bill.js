const { Sales } = require('./lib/sales');

const {
  Attr
} = require('@drumee/server-essentials');

class Bill extends Sales {
  /**
  * 
  */
  async create() {
    let args = this.input.get('args');
    let dest_dir = "/Factures";
    for (let name of ['ht', 'ttc', 'tva']) {
      args[name] = args[name] || 0;
    }

    let bill = await this.db.await_proc('bill_create', args);
    if (!bill || !bill.custId || !bill.chrono) {
      this.exception.server("BILL_FAILED");
      return
    }
    let customer = await this.db.await_proc('customer_get', bill.custId);
    bill = { ...customer, ...bill }
    let data = await this.writeTemplate(bill, {
      template: "bill.fodt",
      dest_dir,
      prefix: "fac"
    });
    if (!data || !data.incoming_file) {
      this.exception.server("BILL_TEMPLATE_FAILED");
      return;
    }
    let node;
    if (data.replace) {
      node = await this.replace(data);
    } else {
      node = await this.store(data)
    }
    this.debug("AAA:40", data, node)
    await this.db.await_proc('bill_update', { docId: node.nid, id: bill.id });
    let work = await this.db.await_proc('work_details', bill.workId);
    this.output.data(work);
  }

  /**
   * 
   */
  async list() {
    const custId = this.input.get('custId');
    const status = this.input.get(Attr.status);
    const page = this.input.get(Attr.page);
    this.debug("AAA:126", JSON.stringify({ custId, page, status }))
    let data = await this.db.await_proc('bill_list', { custId, page, status });
    this.output.list(data);
  }

}


module.exports = Bill;