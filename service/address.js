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
      args.id = addressId;
      res = await this.db.await_proc('address_modify', args)
    }
    this.output.data(res);
  }

  /**
   * 
   */
  async list() {
    const filter = this.input.get('filter') || 'street';
    const page = this.input.get(Attr.page);
    let city = this.input.get('city');
    let street = this.input.get('street');
    let s;
    let args = { city, street, filter, page };
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
    let data = await this.db.await_proc('address_list', args);
    this.output.list(data);
  }

}


module.exports = Customer;