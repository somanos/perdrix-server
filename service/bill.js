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
    await this.db.await_proc('bill_update', { docId: node.nid, id: bill.id });
    let work = await this.db.await_proc('work_details', bill.workId);
    this.output.data(work);
  }

  /**
   * 
   */
  list() {
    return super.list('bill')
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
    // let data = await this.db.await_proc('bill_list', opt);
    // this.output.list(data);
  }

  /**
   * 
   */
  balance() {
    return super.balance('bill')
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
    // let data = await this.db.await_proc('bill_balance', opt);
    // this.output.data(data);
  }

  /**
    * 
    */
  async update() {
    return super.update('bill')
    // const args = this.input.get('args');
    // let data = await this.db.await_proc('bill_update', args);
    // this.output.data(data);
  }

  /**
   * 
   */
  async unassign() {
    const billId = this.input.get(Attr.id) || 0;
    await this.db.await_proc('bill_unassign', billId);
    this.output.data({ billId });
  }

  /**
   * 
   */
  async reassign() {
    const billId = this.input.get(Attr.id) || 0;
    const custId = this.input.get('custId') || 0;
    await this.db.await_proc('bill_reassign', billId, custId);
    this.output.data({ billId });
  }

}


module.exports = Bill;