const { Sales } = require('./lib/sales');
const {
  Attr
} = require('@drumee/server-essentials');

const {
  parse_location, get_geoloc, search_with_address, search_in_table, _search_location, search_location, search, fiscal_years
} = require("./lib/utils")

class Quote extends Sales {

  constructor(...args) {
    super(...args);
    this.fiscal_years = fiscal_years.bind(this);
    this.parse_location = parse_location.bind(this);
    this.get_geoloc = get_geoloc.bind(this);
    this.search_with_address = search_with_address.bind(this);
    this.search_in_table = search_in_table.bind(this);
    this._search_location = _search_location.bind(this);
    this.search_location = search_location.bind(this);
    this.search = search.bind(this);
  }

  /**
   * 
   */
  async create() {
    let args = this.input.get('args');
    let dest_dir = "/Devis";
    for (let name of ['ht', 'ttc', 'tva', 'discount']) {
      args[name] = args[name] || 0;
    }
    args.uid = this.uid;
    let quote = await this.db.await_proc('quote_create', args);
    if (!quote || !quote.custId || !quote.chrono) {
      this.exception.server("QUOTE_FAILED");
      return
    }
    this.debug("AAA:39", quote)
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
    let work = await this.db.await_proc('work_details', { id: quote.workId, uid: this.uid });
    this.output.data(work);
  }

  /**
   * 
   */
  async read() {
    const quoteId = this.input.get(Attr.id) || 0;
    let data = await this.db.await_proc('quote_get', quoteId, this.uid);
    this.output.data(data);
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
  async list() {
    let args = this.input.get('args');
    if (args.address) {
      let words = args.address.replace(/ +/g, '+');
      let features = await this._search_location(words)
      for (let row of features) {
        this.debug("AAA:90", row)
        let { housenumber, street, city, postcode, score } = row.properties;
        if (score <= 0.75) continue;
        let [streettype, streetname] = street.split(/ +/);
        let id = await this.db.await_func('address_get_id',
          housenumber, streettype, streetname, "", postcode, null
        );
        if (id) {
          args.addressId = id;
          break;
        }
        let stop = 0;
        if (housenumber) {
          args.city = housenumber;
          stop = 1;
        }
        if (streettype) {
          args.streettype = streettype;
          stop = 1;
        }
        if (streetname) {
          args.street = streetname;
          stop = 1;
        }
        if (city) {
          args.city = city;
          stop = 1;
        }
        if (postcode) {
          args.postcode = postcode;
          stop = 1;
        }
        if (stop) break;
      }
    }
    return super.list('quote', args)
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