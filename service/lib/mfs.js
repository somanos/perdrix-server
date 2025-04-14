/**
 * @license
 * Copyright 2024 Thidima SA. All Rights Reserved.
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * https://www.gnu.org/licenses/agpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =============================================================================
 */
/**
 * This file is forked from drumee service/media. Shall use drumee-mfs mudule once it's ready
 */
const {
  Attr, Events, Script, toArray, nullValue,
  RedisStore, Cache, sleep, Constants, sysEnv, getFileinfo
} = require("@drumee/server-essentials");
const { DENIED } = Events;
const {
  CATEGORY,
  FAILED_CREATE_FILE,
  FILENAME,
  FILESIZE,
  ORIGINAL,
} = Constants;

const {
  Generator,
  Document,
  FileIo,
  Mfs,
  MfsTools,
} = require("@drumee/server-core");
const { remove_dir, mv } = MfsTools;

const {
  mkdirSync,
  readFileSync,
  statSync,
  writeFileSync,
  existsSync,
  rmSync,
} = require("fs");

const {
  isString,
  map,
  keys,
  isEmpty,
  isArray,
  isFunction,
} = require("lodash");

const {
  data_dir, tmp_dir, server_home, mfs_dir, quota
} = sysEnv();
const { stringify } = JSON;
const { join, resolve, dirname, basename } = require("path");
const Spawn = require("child_process").spawn;
const DATA_ROOT = new RegExp(`^${data_dir}`);
const SPAWN_OPT = { detached: true, stdio: ["ignore", "ignore", "ignore"] };
const OFFLINE_DIR = resolve(server_home, "offline", "media");

class DrumeeMfs extends Mfs {
  /**
   *
   */
  async sendNodeAttributes(args) {
    const { nid, recipients, service, extraData, myData } = args;
    let nodes = {};
    let payload;
    let echoId = this.input.get('echoId');
    for (let r of toArray(recipients)) {
      if (myData && r.uid == this.uid) {
        payload = this.payload({ ...myData, ...extraData }, { echoId, service });
      } else {
        let attr =
          nodes[r.uid] ||
          (await this.db.await_proc("mfs_access_node", r.uid, nid));
        nodes[r.uid] = attr;
        payload = this.payload({ ...attr, ...extraData }, { echoId, service });
      }
      await RedisStore.sendData(payload, r);
    }
  }


  /**
   *
   * @returns
   */
  async make_dir(opt) {
    let { hub_id, pid, ownpath, filename } = opt;
    let uid = this.uid;
    let node = await this.db.await_proc("mfs_get_by_path", ownpath);
    if (!isEmpty(node) && node.id) {
      node = await this.db.await_proc("mfs_access_node", uid, node.id);
      return node
    }
    if (nullValue(ownpath)) {
      filename = filename.replace(/\//g, "-");
      filename = decodeURI(filename);
      let args = {
        owner_id: uid,
        filename,
        pid,
        category: Attr.folder,
        ext: "",
        mimetype: Attr.folder,
        filesize: 0,
        showResults: 1
      };
      node = await this.ensureCreateNode(args, {});
    } else {
      let path = ownpath.split(/\/+/).filter(function (e) {
        return e.length
      });
      let dir = await this.ensureMakeDir(this.home_id, path, 1);
      if (isEmpty(dir) || !dir.nid) {
        this.exception.user("FAILED_CREATE_FOLDER");
        return;
      }
      node = await this.db.await_proc("mfs_access_node", uid, dir.id);
    }

    await this.changelog_write({ src: node });

    if (/^(.|.+\/.+| )$/.test(dirname)) {
      this.exception.user("INVALID_FILENAME");
      return;
    }
    let recipients = await this.yp.await_proc("entity_sockets", {
      hub_id
    });
    recipients = toArray(recipients);
    await this.sendNodeAttributes({
      nid: node.nid,
      recipients,
      service: "media.new",
      myData: node,
    });
    return node;
  }

  /**
   * 
   * @param {*} metadat 
   */
  cleanJson(data) {
    if (!data) return {};
    let tmp;
    if (isString(data)) {
      tmp = JSON.parse(data);
      let exists = {};
      if (isString(tmp._seen_)) {
        let s = toArray(JSON.parse(tmp._seen_));
        let seen = s.filter((e) => {
          let key = keys(e)[0];
          if (exists[key]) return false;
          exists[key] = e[key];
          return /[0-9a-f]{16,16}/i.test(key)
        })
        tmp._seen_ = stringify(seen);
      }
      return tmp;
    }
    return data;
  }

  /**
   * ownpath refers to the absolute path within the hub, nid must be set to hone_id
   * @returns
   */
  async _ensureParentExists() {
    let node = this.granted_node();
    let replace =
      this.input.get("replace") || this.input.get("createOrReplace");
    /** Standard upload, using nid as destination */
    let ownpath = this.input.get(Attr.ownpath);
    this.heap.upload = node;

    if (nullValue(ownpath)) {
      if (this.isBranche(node)) {
        this._mustReplace = false;
      } else {
        if (replace) {
          this._mustReplace = true;
        } else {
          this._mustReplace = false;
        }
      }
      this._done();
      return;
    }
    ownpath = decodeURI(ownpath);
    let { actual_home_id, id } = node;
    if (actual_home_id != this.home_id) {
      this.warn(`Using ownpath implies having same home_id: `,
        `Expected home_id=${this.home_id}, got ${actual_home_id}`,
        "Will bypass"
      )
      return this.exception.server("OWNPATH_INCONSISTENT");
    }

    let filename = basename(ownpath);
    id = await this.db.await_func("node_id_from_path", ownpath);
    if (id) {
      let item = await this.db.await_proc('mfs_access_node', this.uid, id);
      if (item && item.nid) {
        if (this.isBranche(item)) {
          return this.exception.server("CANNOT_REPLACE_FOLDER");
        }
        this._mustReplace = 1;
        this.granted_node(item);
        this.heap.upload = item;
        return this._done();
      }
    }

    let dir = dirname(ownpath).split(/\/+/).filter(function (e) {
      return e.length
    });

    if (!dir.length) {
      this._done();
      return;
    }

    let parent = await this.ensureMakeDir(actual_home_id, dir, 1);
    if (!parent || !parent.nid) {
      return this.exception.server("FAILED_CREATE_FOLDER");
    }
    parent.filepath = join(parent.file_path, filename);
    parent.file_path = parent.filepath;
    this.heap.upload = parent;
    this.granted_node(parent);
    this._done();
  }

  /**
   *
   */
  shouldReplace() {
    if (this._mustReplace != null) {
      return this._mustReplace;
    }
    let node = this.granted_node();

    if (this.isBranche(node)) {
      this._mustReplace = false;
      return this._mustReplace;
    }
    let replace =
      this.input.use("replace") || this.input.use("createOrReplace") || false;
    this._mustReplace = replace;
    return replace;
  }

  /**
   *
   * @returns
   */
  async pre_upload() {
    let json_str;

    if (this.session.isAnonymous()) {
      const token = this.input.use(Attr.token);
      if (isEmpty(token) && isEmpty(this.input.sid())) {
        this.warn("Trying to upload in without token");
        this.trigger(DENIED);
        return;
      }
    }
    let nid = this.input.use(Attr.nid);
    switch (nid) {
      case "-1":
      case "-2":
      case "-3":
      case -1:
      case -2:
      case -3:
        this._done();
        break;

      case -100:
      case "-100":
        const p = this.input.use(Attr.path);
        this.heap.tmp = p;
        json_str = stringify(
          map(p, function (e) {
            return decodeURI(e);
          })
        );
        let d = await this.ensureMakeDir(this.home_id, json_str, 1);
        this.output.data(d);
        break;

      default:
        await this._ensureParentExists();
    }
  }

  /** configure_icon
   * @param {any} nid
   * @param {any} incoming_file - the actual file prepared by core/io
   * @param {string} filename - the actual file prepared by core/io
   */
  async configure_icon(nid, incoming_file, filename) {
    const c = await getFileinfo(incoming_file, filename);
    const ext = c.extension;

    const filepath = join(this.user.get(Attr.home_dir), "__config__", "icons");
    mkdirSync(filepath, { recursive: true });
    if (!existsSync(filepath)) {
      this.warn(`ERROR : ${filepath} not found`);
      this.exception.user(FAILED_CREATE_FILE);
    }

    const orig = `${filepath}/tmp.${ext}`;
    mv(incoming_file, orig)
    Generator.create_avatar(nid, ext, this.user.get(Attr.home_dir), orig);
    this.yp.call_proc("entity_touch", this.user.get(Attr.id), this.output.data);
  }

  /**
   * @param {any} nid - special operation when < 0
   * @param {any}
   * Uploaded files are received by core/io
   * which store the content into io.input->file_path
   */
  async upload() {
    let nid = this.input.use(Attr.nid);
    const incoming_file = this.input.need(Attr.uploaded_file); // internally set by io
    let filename = decodeURI(this.input.need(Attr.filename));
    switch (nid) {
      case -1:
      case -2:
      case -3:
      case "-1":
      case "-2":
      case "-3":
        await this.configure_icon(nid, incoming_file, filename);
        break;

      default:
        let node = this.granted_node();
        if (this.shouldReplace() && isFunction(this.replace)) {
          this.replace(node.id, incoming_file, filename);
        } else {
          if (nid == "0") {
            nid = this.home_id;
          }
          if (this.heap.upload.nid) {
            // set by pre_upload
            nid = this.heap.upload.nid;
          }
          await this.store(nid, incoming_file, filename);
        }
    }
  }

  /**
   * @param {any} nid - node id when reaching MFS area, special operation when < 0
   * @param {any}
   * Uploaded files are received by core/io
   * which store the content into io.input->file_path
   */
  async upload_base64() {
    const image = this.input
      .need(Attr.image)
      .replace(/^data:image\/\w+;base64,/, "");
    const parent = this.source_granted();
    const filename = this.randomString() + "-" + this.input.need(Attr.filename);
    let filepath = resolve(tmp_dir, `${filename}`);
    writeFileSync(filepath, image, { encoding: "base64" });
    await this.store(parent.id, filepath, this.input.need(Attr.filename));
  }

  /**
   *
   */
  async chekcDiskLimit(rid) {
    if (!rid) {
      rid = this.hub.get(Attr.id);
    }
    let curr_filesize = this.input.use(FILESIZE, 0);
    let disk_limit = await this.yp.await_proc("disk_limit", rid) || {};
    let { watermark, owner_id, available_disk } = disk_limit;
    let { watermark: sys_watermark } = quota;
    if (watermark == Infinity || sys_watermark == Infinity) {
      return true;
    }
    let allowed_limit = available_disk || 0;
    if (curr_filesize > allowed_limit) {
      let error = Cache.message("your_limit_exceeded");
      if (this.uid != owner_id) {
        error = Cache.message("limit_exceeded");
      }
      this.exception.user(error);
      return false;
    }
    return true;
  }

  /**
   * Preapre data for storage
   * @returns 
   */
  async before_store(opt) {
    let { incoming_file, filename, pid, filetype, filesize } = opt;
    if (!existsSync(incoming_file)) {
      this.exception.user(FAILED_CREATE_FILE);
      return;
    }

    if (!(await this.chekcDiskLimit())) return;

    const c = await getFileinfo(incoming_file, filename);
    const data = {};
    data.filename = c.filename;
    data.parent_id = pid;
    data.category = c.category;
    data.extension = c.extension;
    data.mimetype = c.mimetype;
    data.geometry = "0x0";
    data.filesize = filesize || 0;

    if (filetype) data.category = filetype;
    this.debug("AAA:471", opt, c, data)
    return data;
  }

  /**
   * 
   */
  async notifyNewNode(node) {
    const { nid, hub_id } = node;
    let exclude = [this.input.get(Attr.socket_id)];
    let recipients = await this.yp.await_proc("entity_sockets", {
      hub_id,
      exclude,
    });
    await this.sendNodeAttributes({
      nid,
      recipients,
      service: "media.new",
      myData: node
    });
  };


  /**
 * In case of massive write, DB dead lock may appear
 * Retry until dead lock left or too much rety 
 */
  async ensureMakeDir(id, path, showResult) {
    let ownpath = join('/', ...path);
    let exists = await this.db.await_func("node_id_from_path", ownpath);
    let node = await this.db.await_proc("mfs_make_dir", id, path, showResult);
    let i = 0;
    while (node[1] && node[1].sqlstate == '40001' && i < 30) {
      await sleep(500);
      node = await this.db.await_proc("mfs_make_dir", id, path, showResult);
      i++;
    }
    if (!exists && node.nid) {
      await this.notifyNewNode(node);
    }
    if (i > 29) {
      this.warn(`DEAD_LOCK_WAIT_TOOL_LONG. mfs_make_dir waited ${i} times`, node)
    }
    return node;
  }

  /**
   * In case of massive write, DB dead lock may appear
   * Retry until dead lock left or too much rety 
   */
  async ensureCreateNode(args, metadata, results = { isOutput: 1 }) {
    let node = await this.db.await_proc("mfs_create_node", args, metadata, results);
    let i = 0;
    while (node[1] && node[1].sqlstate == '40001' && i < 30) {
      await sleep(500);
      node = await this.db.await_proc("mfs_create_node", args, metadata, results);
      i++;
    }
    if (i > 29) {
      this.warn(`DEAD_LOCK_WAIT_TOOL_LONG. mfs_create_node waited ${i} times`, node)
    }
    return node;
  }

  /**
   *
   * @param {*} pid
   * @param {*} incoming_file
   * @param {*} filename
   * @param {*} callback
   * @returns
   */
  async store(opt, service = 'media.new') {
    let {
      pid, incoming_file, filename, filesize,
      metadata, md5Hash, parent, filetype
    } = opt;
    let error;

    if (!pid) {
      error = `REQUIRE_PARENT_ID`;
      this.exception.server(error);
      return { error };
    }
    let uid = this.uid;
    if (isEmpty(parent) || !parent.nid) {
      error = `PERMISSION_DENIED`;
      this.exception.server(error);
      return { error };
    }

    let parent_of = await this.db.await_func("is_parent_of", parent.nid, pid);
    this.debug("AAA:527", parent_of,parent,  parent.nid, pid)
    if (!parent_of && parent.nid != pid) {
      error = `WRONG_FILEPATH`;
      this.exception.server(error);
      return { error };
    }
    const data = await this.before_store({
      incoming_file, filename, pid, filetype, filesize
    });

    if (isEmpty(data)) {
      return { error: "failed_to_store" };
    }
    filename = data.filename || this.randomString();
    if (filename.length > 126) {
      filename = filename.slice(0, 126);
    }

    let args = {
      owner_id: uid,
      filename,
      pid,
      category: data[CATEGORY],
      ext: data.extension,
      mimetype: data.mimetype,
      filesize: data.filesize,
      showResults: 1
    }
    metadata = metadata || {}
    if (metadata) {
      if (isString(metadata)) {
        metadata = JSON.parse(metadata);
      }
    }
    metadata.md5Hash = md5Hash;
    let node = await this.ensureCreateNode(args, metadata);
    this.debug("AAA:536", args, node)

    if (!node || !node.id) {
      this.exception.server(`Failed to save file ${filename}`);
      return { error: "failed_to_store" };
    }
    let res = await this.after_store({ pid, incoming_file, node });
    if (res.error || res.done) {
      return;
    }

    await this.changelog_write({ src: res, event: service })
    let hub_id = this.hub.get(Attr.id);
    let recipients = await this.yp.await_proc("entity_sockets", {
      hub_id,
    });

    await this.sendNodeAttributes({
      nid: res.nid,
      recipients,
      service,
      myData: res
    });
    return res;

  }

  /**
 *
 */
  async handleForm(incoming_file, data) {
    let error;
    if (this.shouldReplace()) {
      error = "UNSUPPORTED_REPLACE";
      this.exception.user(error);
      return { error };
    }
    let form = readFileSync(incoming_file) || {};
    let definition = form.schema;
    let keys = form.keys;
    if (form.type != Attr.form || !definition) return;
    let name = `form_${data.id}`;
    let k, def, key;
    let sql = `CREATE TABLE IF NOT EXISTS ${name} (`;
    if (!keys) {
      definition.sys_id = "int(11) unsigned NOT NULL AUTO_INCREMENT";
      keys = {
        primary: "sys_id",
      };
    }

    if (!keys.primary) keys.primary = "sys_id";

    for (k in definition) {
      def = definition[k];
      sql = `${sql} ${k} ${def},`;
    }
    sql = `${sql} primary key (\`${keys.primary}\`),`;
    if (isArray(keys.unique)) {
      for (k in keys.unique) {
        let key = keys.unique[k];
        if (!definition[key]) continue;
        sql = `${sql} unique key (\`${key}\`),`;
      }
    }
    if (isArray(keys.index)) {
      for (k in keys.index) {
        let key = keys.index[k];
        if (!definition[key]) continue;
        sql = `${sql} unique key (\`${key}\`),`;
      }
    }
    sql = sql.replace(/,$/, ")");
    let r = await this.db.await_run(sql);
    if (r.errno) {
      this.exception.user(r.text);
      return { error: "FAILED_TO_CREATE_TABLE", message: r.text };
    }
    let writeHtml = require("@drumee/server-core/template");

    let html_file = writeHtml({ ...data, ...form });
    let filesize = 0;
    if (existsSync(master)) {
      filesize = statSync(html_file).size;
    }
    let filename = data.filename.replace(/\.form+$/, ".html");
    let args = {
      owner_id: this.uid,
      filename,
      pid,
      category: 'web',
      ext: 'html',
      mimetype: 'text/html',
      filesize,
      showResults: 1
    }
    let lines = readFileSync(html_file);
    let { createHash } = require("crypto");

    let md5Hash = createHash("md5");
    md5Hash.update(Buffer.from(lines));
    let metadata = { md5Hash };

    let node = this.ensureCreateNode(args, metadata);
    await this.sendNodeAttributes({
      nid: node.nid,
      recipients,
      service,
      myData: node
    });

    return { ...node, done: 1 };
  }

  /**
   *
   * @param {*} node
   */
  _convertToPdf(node) {
    let socket_id = this.input.get(Attr.socket_id);
    let args = {
      node,
      uid: this.uid,
      socket_id,
    };

    let cmd = resolve(OFFLINE_DIR, "to-pdf.js");
    let child = Spawn(cmd, [JSON.stringify(args)], SPAWN_OPT);
    child.unref();
  }

  /**
   *
   */
  toPdf() {
    this._convertToPdf(this.granted_node());
    this.output.data({ buildState: "wait" });
  }

  /**
   *
   * @param {*} data
   */
  async handlePdf(incoming_file, data) {
    const { writeFileSync } = require("jsonfile");
    //let exclude = [this.input.get(Attr.socket_id)];
    const raw_data = { ...data };
    data.replace = this.shouldReplace();

    const base = resolve(data.mfs_root, data.id);
    const ext = data.extension.toLowerCase();
    let orig = join(base, `orig.${ext}`);
    let info = join(base, "info.json");
    mkdirSync(base, { recursive: true });
    let docInfo = { buildState: Attr.working };
    if (!mv(incoming_file, orig)) {
      this.exception.server('FILE_ERROR');
      return
    }
    rmSync(info, { force: true });
    writeFileSync(info, docInfo);
    data.position = this.input.get(Attr.position) || 0;
    let recipients = await this.yp.await_proc(
      "entity_sockets",
      {
        hub_id: this.hub.get(Attr.id),
        //exclude,
      }
    );
    this._convertToPdf({ ...raw_data, ...data });
    if (!data.replace) {
      await this.sendNodeAttributes({
        nid: data.nid,
        recipients,
        service: "media.new",
        myData: data,
      });
    } else {
      await this.sendNodeAttributes({
        nid: data.nid,
        recipients,
        service: "media.replace",
        myData: data,
        extraData: { buildState: "wait" },
      });
    }
  }

  /**
   * 
   */
  async changelog_write(opt) {
    let { src, dest, event } = opt;
    let { metadata, md5Hash } = src;
    if (!md5Hash && metadata && metadata.md5Hash) {
      src.md5Hash = metadata.md5Hash;
    }
    delete src.metadata;

    if (dest) {
      let { metadata, md5Hash } = dest;
      if (!md5Hash && metadata && metadata.md5Hash) {
        dest.md5Hash = metadata.md5Hash;
      }
      delete dest.metadata;
    } else {
      dest = '{}';
    }
    if (!event) {
      event = this.input.get(Attr.service);
    }
    let changelog;
    try {
      if (/^\/__chat__\//.test(src.filepath) || /^\/__chat__\//.test(dest.filepath)) {
        this.__changelog = null;
        return this.__changelog;
      }
      changelog = await this.yp.await_proc(
        `changelog_write`, this.uid, this.hub.get(Attr.id), event, src, dest
      );
    } catch (e) {
      this.warn("changelog_write failed:", e)
    }
    this.__changelog = changelog
    return changelog;
  }

  /**
   * 
   * @param {*} incoming_file 
   * @param {*} node 
   * @returns 
   */
  async after_store(opt) {
    let { pid, incoming_file, position = 0, node } = opt;
    const base = resolve(node.mfs_root, node.id);
    mkdirSync(base, { recursive: true });
    const ext = node.extension.toLowerCase();
    let orig = `${base}/orig.${ext}`;
    this.granted_node(node);
    if (node.filetype == Attr.document && node.extension != Attr.pdf) {
      if (!this.handlePdf(incoming_file, node)) {
        node.error = 1;
      }
      return node;
    }
    if (node.filetype == Attr.form) {
      let content = await this.handleForm(pid, incoming_file, node);
      return content;
    }

    if (!mv(incoming_file, orig) || !existsSync(orig)) {
      this.warn(`${__filename}:337 ${orig} not found`);
      this.exception.user(FAILED_CREATE_FILE);
      return { ...node, error: 1 };
    }

    // Force information generation
    if (node.filetype == Attr.document && node.extension == Attr.pdf) {
      Document.getInfo(node);
    }

    node.position = position;

    return node;
  }

  /**
   * 
   */
  async mark_as_seen() {
    const nid = this.input.need(Attr.nid);
    let data = await this.db.await_proc(
      "mfs_mark_as_seen",
      nid,
      this.uid,
      1
    );
    let recipients = await this.yp.await_proc("user_sockets", this.uid);
    let keys = { entity_id: Attr.hub_id };
    await RedisStore.sendData(this.payload(data, { keys }), recipients);
    await RedisStore.sendData(
      this.payload({}, { service: "notification.resync" }),
      recipients
    );
    this.output.data(data);
  }


  /**
   *
   */
  async pdf(node) {
    //const nid = this.input.need(Attr.nid);
    if (node.filetype != Attr.document) {
      this.exception.user("WRONG_FORMAT");
      return;
    }
    let info = Document.getInfo(node);
    const fileio = new FileIo(this);
    let path = info.pdf;
    if (path != null) {
      if (!existsSync(path)) {
        let s = Document.rebuildInfo(
          node,
          this.uid,
          this.input.get(Attr.socket_id)
        );
        if (s.path) {
          path = s.path;
        } else {
          this.output.data(s);
          return;
        }
      }
      const opt = {
        name: `${node.filename}.pdf`,
        path,
        accel: path.replace(DATA_ROOT, ""),
        mimetype: "application/pdf",
        code: 200,
      };
      fileio.static(opt);
    } else {
      fileio.not_found();
    }
  }



  /**
   * 
   */
  async orig() {
    await this.send_media(this.source_granted(), ORIGINAL);
  }

  /**
   * 
   * @returns 
   */
  async raw() {
    let filepath;
    let p = this.input.need("p");
    const e = this.input.use("e");
    if (p.match(/(\/+)$/)) {
      p = p.replace(/(\/+)$/, "");
      filepath = `/${p}`;
    } else if (!isEmpty(e)) {
      filepath = `/${p}.${e}`;
    } else {
      filepath = p;
    }
    filepath = `/${filepath}`;
    filepath = filepath.replace(/^(\/+)/, "/");
    filepath = decodeURI(filepath);
    let data = await this.db.await_proc("mfs_get_by_path", filepath);

    if (!isEmpty(data) && data.id) {
      try {
        let md = data.metadata;
        if (isString(md)) md = JSON.parse(md);

        if (md && md.loader) {
          let file = resolve(
            this.granted_node().home_dir,
            data.id,
            `orig.${data.extension}`
          );
          let loader = readFileSync(file);
          loader = String(loader).trim().toString();
          const Bootstrap = require("../client/bootstrap");
          let b = new Bootstrap(this);
          let c = await b.htmlContent(md.loader, md);
          this.output.html(c);
          b.stop();
          return;
        }
      } catch (e) {
        this.warn("FAILED TO GET HTML CONTENT", e);
      }
      await this.send_media(data.id, ORIGINAL, null, "raw");
      if (this.input.get("xid")) {
        this.session.log_service();
      }
      return;
    }
    const fileio = new FileIo(this);
    fileio.not_found(filepath);
  }


  /**
   * @param {any}
   * @param {any}
   * Save content into FMS node
   */
  async save(opt) {
    let { content, filename, pid, nid, metadata = {} } = opt;
    let { createHash } = require("crypto");
    let hash = createHash("md5");
    let chunk = Buffer.from(content, "utf8");
    hash.update(chunk);
    let md5Hash = hash.digest("hex");

    const tmp_file = this.randomString() + "-" + filename;
    let incoming_file = resolve(tmp_dir, `${tmp_file}`);
    writeFileSync(incoming_file, content, { encoding: "utf-8" });

    if (nid) {
      let attr = await this.db.await_proc("mfs_access_node", this.uid, nid);
      if (isEmpty(attr)) {
        await this.store({
          pid, incoming_file, filename, md5Hash
        });
      } else {
        await this.db.await_proc("mfs_set_metadata", nid, metadata, 0);
        await this.replace_content(
          attr,
          incoming_file,
          filename,
          md5Hash
        );
      }
    } else {
      await this.store({
        pid, incoming_file, filename, md5Hash
      });
    }
  }


  /**
   * replace existing media by uploaded file
   * @param {*} nid 
   * @param {*} incoming_file 
   * @param {*} filename 
   * @returns 
   */
  async replace(opt) {
    let { incoming_file, filename, node, filesize, pid } = opt;
    let { filetype } = node;
    if (/^(folder|root)$/.test(filetype)) {
      this.warn("COULD NOT REPLACE FOLDER", this.input.use(Attr.filepath), node);
      this.exception.user("TARGET_IS_FOLDER_OR_ROOT");
      return;
    }
    let md5Hash = this.input.get("md5Hash");
    let { metadata } = node;
    metadata = this.cleanJson(metadata);
    metadata.md5Hash = md5Hash;
    node.privilege = node.permission;
    let data = await this.before_store(
      { incoming_file, filename, pid, filetype, filesize }
    );
    data.rtime = Math.floor(new Date().getTime() / 1000);
    data.publish_time = data.rtime;
    if (data.filename) {
      data.user_filename = data.filename.replace(`.${data.extension}`, "");
    }

    await this.db.await_proc("mfs_set_node_attr", nid, data, 0);
    await this.db.await_proc("mfs_set_metadata", nid, metadata, 0);
    node.metadata = metadata;
    await this.after_store({ pid: node.pid, incoming_file, position, node });
    node = await this.db.await_proc("mfs_access_node", this.uid, nid);
    if (node.filetype == Attr.document) {
      Document.rebuildInfo(
        node,
        this.uid,
        this.input.get(Attr.socket_id)
      )
    }
    return node;
  }

  /**
   * 
   * @param {*} node 
   * @param {*} incoming_file 
   * @param {*} filename 
   * @param {*} hash 
   * @returns 
   */
  async replace_content(node, incoming_file, filename, hash) {
    node.privilege = node.permission;
    let data = await this.before_store(incoming_file, filename, {
      nid: node.parent_id,
    });
    if (!data) {
      return;
    }
    if (/^(folder|root)$/.test(node.filetype)) {
      this.exception.user("TARGET_IS_FOLDER_OR_ROOT");
      return;
    }
    data.rtime = Math.floor(new Date().getTime() / 1000);
    data.publish_time = data.rtime;
    data.changed_time = data.rtime;
    if (data.filename) {
      data.user_filename = data.filename.replace(`.${data.extension}`, "");
    }
    node = await this.db.await_proc("mfs_set_node_attr", node.nid, data, 1);
    node.extension = data.extension;
    this._mustReplace = 1;
    let attr = await this.after_store(
      data.parent_id,
      incoming_file,
      node
    );
    this.output.data({ ...node, ...attr, replace: 1 });
  }

}
module.exports = { DrumeeMfs };