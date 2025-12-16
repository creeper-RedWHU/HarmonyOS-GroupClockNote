import relationalStore from '@ohos.data.relationalStore';
import {UserInform} from './Entities/UserInform'
import { User } from './Entities/User';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
const DB_NAME = 'database.db';

export class PasswordUtil {
  genKeyMaterialBlob(data: Array<number>): cryptoFramework.DataBlob {
    let keyMaterial = new Uint8Array(data);
    return { data: keyMaterial };
  }
  // SHA256 加密
  hashPassword(password: string): string {
    // let md = cryptoFramework.createMd("SHA256");
    // // 必须转成Uint8Array/DataBlob类型
    // let data:cryptoFramework.DataBlob =
    //   this.genKeyMaterialBlob(Array.from(password).map(c => c.charCodeAt(0)));
    // md.update(data);
    // const digestBlob = md.digest();
    // // digestBlob.data 是 Uint8Array
    // return Array.from(digestBlob.data).map(b => b.toString(16).padStart(2, '0')).join('');
    return password;
  }
}

//==========userDBManager==========
export class UserDBManager {
  private static rdbStore: relationalStore.RdbStore | null = null;
  static async initialize(context: Context) {
    console.log("initial database")
    if (!UserDBManager.rdbStore) {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1,
        encrypt: false, // 可选：true为开启加密
      };
      // 打开或创建数据库
      UserDBManager.rdbStore = await relationalStore.getRdbStore(context, config);
      // 创建表
      await UserDBManager.createTable();
    }
    return UserDBManager.rdbStore;
  }
  private static async createTable() {
    if (!UserDBManager.rdbStore) return;
    //userLOGIN Table
    await UserDBManager.rdbStore.executeSql(
      `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      );`
    );
    //userInformation Table
    await UserDBManager.rdbStore.executeSql(
      `CREATE TABLE IF NOT EXISTS userInformation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,     -- 关联用户，假设和users表内id关联
        phone TEXT,                   -- 手机号
        email TEXT,                   -- 邮箱
        gender TEXT,                  -- 性别（可以用TEXT，比如"男"/"女"/"其他"，也可用INT映射）
        created_at TEXT,
        updated_at TEXT
      );`
    );
    //matter_information
    await UserDBManager.rdbStore.executeSql(
      `CREATE TABLE IF NOT EXISTS matter_information (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,      -- 关联合适userInformation表的id
        ascription_time TEXT NOT NULL, -- 归属时间
        category TEXT NOT NULL,        -- 事务分类
        content TEXT NOT NULL,         -- 事务内容
        finished INTEGER NOT NULL DEFAULT 0,  -- 完成状态
        created_at TEXT,
        updated_at TEXT
      );`
    );
  }
  static getStore(): relationalStore.RdbStore | null { return UserDBManager.rdbStore; }
}
//==========Dao==========
//==========User LOGIN Dao==========
export class UserDao {
  //==========注册==========
  // 注册: 查重账号, 不能同名
  static async registerUser(name: string, password: string): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    // 查重
    const predicate = new relationalStore.RdbPredicates('users');
    predicate.equalTo('name', name);
    const result = await rdbStore.query(predicate, ['id']);
    if (result.rowCount > 0) throw new Error('用户名已存在');
    result.close();

    // 插入
    const now = Math.floor(Date.now() / 1000).toString();
    const valueBucket: relationalStore.ValuesBucket = {
      name,
      password,
      created_at: now,
      updated_at: now
    };
    const rowId = await rdbStore.insert('users', valueBucket);
    return rowId;
  }
  //==========登录==========
  // 登录 & 精确查询账号
  static async getUserByName(name: string): Promise<User> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('users');
    predicate.equalTo('name', name);
    const result = await rdbStore.query(predicate, ['id', 'name', 'password', 'created_at', 'updated_at']);
    if (result.rowCount === 0) return new User(
      'name',
      'x',
      -1,
      'x',
      'x'
    );
    result.goToFirstRow();

    const user = new User(
      result.getString(result.getColumnIndex('name')),
      result.getString(result.getColumnIndex('password')),
      result.getLong(result.getColumnIndex('id')),
      result.getString(result.getColumnIndex('created_at')),
      result.getString(result.getColumnIndex('updated_at'))
    );
    result.close();
    return user;
  }
  //==========查询==========
  // 按 id 查询
  static async getUserById(id: number): Promise<User | null> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('users');
    predicate.equalTo('id', id);
    const result = await rdbStore.query(predicate, ['id', 'name', 'password', 'created_at', 'updated_at']);
    if (result.rowCount === 0) return null;
    result.goToFirstRow();

    const user = new User(
      result.getString(result.getColumnIndex('name')),
      result.getString(result.getColumnIndex('password')),
      result.getLong(result.getColumnIndex('id')),
      result.getString(result.getColumnIndex('created_at')),
      result.getString(result.getColumnIndex('updated_at'))
    );
    result.close();
    return user;
  }
  // 删除
  static async deleteUserById(id: number): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('users');
    predicate.equalTo('id', id);
    const rowsDeleted = await rdbStore.delete(predicate);
    return rowsDeleted;
  }

  // 修改账号（用户名），注意查重
  static async updateUserName(id: number, newName: string): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    // 查重
    const predicateDup = new relationalStore.RdbPredicates('users');
    predicateDup.equalTo('name', newName);
    const resultDup = await rdbStore.query(predicateDup, ['id']);
    if (resultDup.rowCount > 0) throw new Error('用户名已存在');
    resultDup.close();

    // 更新
    const updateBucket: relationalStore.ValuesBucket = {
      name: newName,
      updated_at: Math.floor(Date.now() / 1000).toString()
    };
    const predicate = new relationalStore.RdbPredicates('users');
    predicate.equalTo('id', id);
    const rowsUpdated = await rdbStore.update(updateBucket, predicate);
    return rowsUpdated;
  }

  // 修改密码
  static async updateUserPassword(id: number, newPassword: string): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const updateBucket: relationalStore.ValuesBucket = {
      password: newPassword,
      updated_at: Math.floor(Date.now() / 1000).toString()
    };
    const predicate = new relationalStore.RdbPredicates('users');
    predicate.equalTo('id', id);
    const rowsUpdated = await rdbStore.update(updateBucket, predicate);
    return rowsUpdated;
  }
}
//==========User INFORMATION Dao==========
export interface UserInformationFields {
  phone?: string;
  email?: string;
  gender?: string;
}
export class UserInformationDao {

  // 增（插入用户信息）
  static async addUserInformation(user_id: number, phone: string, email: string, gender: string): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');

    const now = new Date().toISOString();
    const valueBucket: relationalStore.ValuesBucket = {
      user_id,
      phone,
      email,
      gender,
      created_at: now,
      updated_at: now
    };
    const rowId = await rdbStore.insert('userInformation', valueBucket);
    return rowId;
  }

  // 查（通过 user_id 查询单条信息）
  static async getUserInformationByUserId(user_id: number): Promise<UserInform | null> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('userInformation');
    predicate.equalTo('user_id', user_id);
    const result = await rdbStore.query(predicate, ['id', 'user_id', 'phone', 'email', 'gender', 'created_at', 'updated_at']);
    if (result.rowCount === 0) {
      result.close();
      return null;
    }
    result.goToFirstRow();
    const info = new UserInform(
      result.getLong(result.getColumnIndex('user_id')),
      result.getString(result.getColumnIndex('phone')),
      result.getString(result.getColumnIndex('email')),
      result.getString(result.getColumnIndex('gender')),
      result.getLong(result.getColumnIndex('id')),
      result.getString(result.getColumnIndex('created_at')),
      result.getString(result.getColumnIndex('updated_at'))
    );
    result.close();
    return info;
  }

  // 改（更新用户信息，要求 user_id 唯一）
  static async updateUserInformation(user_id: number, fields: UserInformationFields): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const valueBucket: relationalStore.ValuesBucket = {};
    if (fields.phone !== undefined) valueBucket.phone = fields.phone;
    if (fields.email !== undefined) valueBucket.email = fields.email;
    if (fields.gender !== undefined) valueBucket.gender = fields.gender;
    valueBucket.updated_at = new Date().toISOString();
    const predicate = new relationalStore.RdbPredicates('userInformation');
    predicate.equalTo('user_id', user_id);
    const rowsUpdated = await rdbStore.update(valueBucket, predicate);
    return rowsUpdated;
  }

  // 删（通过 user_id 删除）
  static async deleteUserInformationByUserId(user_id: number): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('userInformation');
    predicate.equalTo('user_id', user_id);
    const rowsDeleted = await rdbStore.delete(predicate);
    return rowsDeleted;
  }
}
//==========matter_information Dao==========

//==========Matter INFORMATION Dao==========
export interface MatterInformationFields {
  user_id?: number;
  ascription_time?: string;
  category?: string;
  content?: string;
  finished?: number;
}

export class MatterInform {
  public user_id: number;
  public ascription_time: string;
  public category: string;
  public content: string;
  public finished: number;
  public id: number;
  public created_at: string;
  public updated_at: string;

  constructor(
  user_id: number,
  ascription_time: string,
  category: string,
  content: string,
  finished: number,
  id: number=-1,
  created_at: string='',
  updated_at: string='',
  ) {
  this.user_id = user_id;
  this.ascription_time = ascription_time;
  this.category = category;
  this.content = content;
  this.finished = finished;
  this.id = id;
  this.created_at = created_at;
  this.updated_at = updated_at;
}
}

interface GeneratedTypeLiteralInterface_1 {
  user_id: number;
  ascription_time: string;
  category: string;
  content: string;
  finished?: number;
}

export class MatterInformationDao {
  // 1. 根据uid查找
  static async getMatterByUserId(user_id: number): Promise<MatterInform[]> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('matter_information');
    predicate.equalTo('user_id', user_id);
    const result = await rdbStore.query(
      predicate,
      ['id', 'user_id', 'ascription_time', 'category', 'content', 'finished', 'created_at', 'updated_at']
    );
    const matters: MatterInform[] = [];
    if (result.rowCount === 0) {
      result.close();
      return matters;
    }
    for (result.goToFirstRow(); result.rowIndex < result.rowCount; result.goToNextRow()) {
      matters.push(new MatterInform(
        result.getLong(result.getColumnIndex('user_id')),
        result.getString(result.getColumnIndex('ascription_time')),
        result.getString(result.getColumnIndex('category')),
        result.getString(result.getColumnIndex('content')),
        result.getLong(result.getColumnIndex('finished')),
        result.getLong(result.getColumnIndex('id')),
        result.getString(result.getColumnIndex('created_at')),
        result.getString(result.getColumnIndex('updated_at')),
      ));
    }
    result.close();
    return matters;
  }

  // 2. 根据日期查找
  static async getMatterByDate(ascription_time: string): Promise<MatterInform[]> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('matter_information');
    predicate.equalTo('ascription_time', ascription_time);
    const result = await rdbStore.query(
      predicate,
      ['id', 'user_id', 'ascription_time', 'category', 'content', 'finished', 'created_at', 'updated_at']
    );
    const matters: MatterInform[] = [];
    if (result.rowCount === 0) {
      result.close();
      return matters;
    }
    for (result.goToFirstRow();  result.rowIndex < result.rowCount; result.goToNextRow()) {
      matters.push(new MatterInform(
        result.getLong(result.getColumnIndex('user_id')),
        result.getString(result.getColumnIndex('ascription_time')),
        result.getString(result.getColumnIndex('category')),
        result.getString(result.getColumnIndex('content')),
        result.getLong(result.getColumnIndex('finished')),
        result.getLong(result.getColumnIndex('id')),
        result.getString(result.getColumnIndex('created_at')),
        result.getString(result.getColumnIndex('updated_at')),
      ));
    }
    result.close();
    return matters;
  }

  // 3. 根据uid和日期联合查找
  static async getMatterByUserIdAndDate(user_id: number, ascription_time: string): Promise<MatterInform[]> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('matter_information');
    predicate.equalTo('user_id', user_id).equalTo('ascription_time', ascription_time);
    const result = await rdbStore.query(
      predicate,
      ['id', 'user_id', 'ascription_time', 'category', 'content', 'finished', 'created_at', 'updated_at']
    );
    const matters: MatterInform[] = [];
    if (result.rowCount === 0) {
      result.close();
      return matters;
    }
    for (result.goToFirstRow(); result.rowIndex < result.rowCount; result.goToNextRow()) {
      matters.push(new MatterInform(
        result.getLong(result.getColumnIndex('user_id')),
        result.getString(result.getColumnIndex('ascription_time')),
        result.getString(result.getColumnIndex('category')),
        result.getString(result.getColumnIndex('content')),
        result.getLong(result.getColumnIndex('finished')),
        result.getLong(result.getColumnIndex('id')),
        result.getString(result.getColumnIndex('created_at')),
        result.getString(result.getColumnIndex('updated_at')),
      ));
    }
    result.close();
    return matters;
  }

  // 4. 根据传入的参数增加表项
  static async addMatter(fields: GeneratedTypeLiteralInterface_1): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const now = new Date().toISOString();
    const valueBucket: relationalStore.ValuesBucket = {
      user_id: fields.user_id,
      ascription_time: fields.ascription_time,
      category: fields.category,
      content: fields.content,
      finished: fields.finished ?? 0,
      created_at: now,
      updated_at: now
    };
    const rowId = await rdbStore.insert('matter_information', valueBucket);
    return rowId;
  }

  // 5. 根据传入的事务id删除
  static async deleteMatterById(id: number): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const predicate = new relationalStore.RdbPredicates('matter_information');
    predicate.equalTo('id', id);
    const rowsDeleted = await rdbStore.delete(predicate);
    return rowsDeleted;
  }

  // 6. 根据传入的事务id和对应的可能字段修改
  static async updateMatterById(id: number, fields: MatterInformationFields): Promise<number> {
    const rdbStore = UserDBManager.getStore();
    if (!rdbStore) throw new Error('Database not initialized');
    const valueBucket: relationalStore.ValuesBucket = {};
    if (fields.user_id !== undefined) valueBucket.user_id = fields.user_id;
    if (fields.ascription_time !== undefined) valueBucket.ascription_time = fields.ascription_time;
    if (fields.category !== undefined) valueBucket.category = fields.category;
    if (fields.content !== undefined) valueBucket.content = fields.content;
    if (fields.finished !== undefined) valueBucket.finished = fields.finished;
    valueBucket.updated_at = new Date().toISOString();
    const predicate = new relationalStore.RdbPredicates('matter_information');
    predicate.equalTo('id', id);
    const rowsUpdated = await rdbStore.update(valueBucket, predicate);
    return rowsUpdated;
  }
}
