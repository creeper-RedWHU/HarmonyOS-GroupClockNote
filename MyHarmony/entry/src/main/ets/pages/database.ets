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
