const { Entity } = require('@drumee/server-core');
const {
  Attr
} = require('@drumee/server-essentials');

class Customer extends Entity {
  /**
   * 
   */
  async merge() {
    const {
      srcId,
      destId,
    } = this.input.data()
    this.debug("AAA:17", srcId, destId)
    let res = await this.db.await_proc('address_merge', srcId, destId)
    this.output.data(res);
  }

  /**
   * 
   */
  async modify() {
    let args = this.input.get('args')
    const {
      housenumber,
      streettype,
      streetname,
      additional,
      postcode,
      addressId,
      countrycode
    } = args
    this.debug("AAA:17", addressId, housenumber, streettype, streetname, additional, postcode, countrycode)
    let id = await this.db.await_func('address_get_id',
      housenumber, streettype, streetname, additional, postcode, countrycode
    );
    let res = {}
    if (id) {
      if (addressId == id) {
        args.id = id;
        res = await this.db.await_proc('address_modify', args)
      } else {
        let dest = await this.db.await_proc('address_get', id)
        let src = await this.db.await_proc('address_get', addressId)
        this.output.data({ src, dest });
        return
      }
    } else {
      this.debug(`AAA:26 -- update on ${addressId}`)
      args.id = addressId;
      res = await this.db.await_proc('address_modify', args)
    }
    this.output.data(res);
  }

  /**
   * 
   */
  async list() {
    const sort_by = this.input.get(Attr.sort_by) || 'street';
    const order = this.input.get(Attr.order) || 'asc';
    const page = this.input.get(Attr.page);
    let city = this.input.get('city');
    let street = this.input.get('street');
    let s;
    let args = { city, street, sort_by, order, page };
    if (street) {
      s = street.split(/[ ,]+/);
      if (/[0-9]+/.test(s[0])) {
        args.housenumber = s[0];
        if (s.length == 2) {
          args.street = s[1];
        } else if (s.length >= 3) {
          args.streettype = s[1];
          s.shift();
          s.shift();
          args.street = s.join(' ');
        }
      } else if (s.length == 2) {
        args.streettype = s[0];
        args.street = s[1];
      } else if (s.length >= 3) {
        args.streettype = s[0];
        s.shift();
        args.street = s.join(' ');
      }
    }
    this.debug("AAA:17", JSON.stringify(args))
    let data = await this.db.await_proc('address_list', args);
    this.output.list(data);
  }

}


module.exports = Customer;