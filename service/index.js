const { Entity } = require('@drumee/server-core');
const {
  Cache, toArray, Attr, RedisStore
} = require('@drumee/server-essentials');
const { resolve } = require('path');
console.log("PERDRIXXXXXXXXXXXXXXXXXX")
class Perdrix extends Entity {

  /**
   * 
   */
  async list_client() {

    this.output.data({});
  }


  /**
    * 
  */
  async seo() {
    this.output.data({});
  }


}


module.exports = Perdrix;