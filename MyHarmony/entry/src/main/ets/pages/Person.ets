import {UserInformationDao} from './database'
import {UserInformationFields} from './database'
import {CustomDialogExample} from './example';
import { promptAction } from '@kit.ArkUI';

class  Pair{
  x:string;
  y:string;
  constructor(xx:string,yy:string) {
    this.x=xx;
    this.y=yy;
  }
}
@Component
export struct Person{
  pathInfos:NavPathStack=new NavPathStack();
  name:string='';
  userID:number=-1;
  @State userPhone:string='';
  @State userEmail:string='';
  @State userGender:string='';
  @State userCreated_at:string='';
  @State userUpdated_at:string='';
  result:string='';
  @State displayName:string = '';
  @State origValue:string = '';
  @State changeColumn:string = '';

  private listArray: Array<string> = ['userPhone','userEmail','userGender','userCreated_at','userUpdated_at'];
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: ()=> { this.onCancel() },
      confirm:this.onAccept.bind(this)
    }),
  })

  onCancel() {
    console.info('Callback when the first button is clicked');
  }

  async onAccept(x:string) {
    console.info('Callback when the second button is clicked'+x);
    this.result=x;
    await this.changeUserData(this.changeColumn,this.result);
  }
  dictionChange(origin:string):Pair{
    let x:string,y:string;
    switch (origin) {
      case 'userPhone':
        x = '手机号';
        y = this.userPhone;
        break;
      case 'userEmail':
        x = '邮箱';
        y = this.userEmail;
        break;
      case 'userGender':
        x = '性别';
        y = this.userGender;
        break;
      case 'userCreated_at':
        x = '创建时间';
        y = this.userCreated_at;
        break;
      case 'userUpdated_at':
        x = '更新时间';
        y = this.userUpdated_at;
        break;
      default:
        x = origin;
        y = '';
        break;
    }
    if(y.length === 0)y='点击设置';
    return new Pair(x, y);


	}

  async getUserData(): Promise<void>{
    //如果没有就创建
    //如果有就调取

    // 查 userInformation
    console.log('called get UserData')
    const info = await UserInformationDao.getUserInformationByUserId(this.userID);
    if (!info) {
      // 无则创建一条，先只填 user_id
      await UserInformationDao.addUserInformation(this.userID, '', '', '');
      console.log('success init Person');
      // 再取一次
      const newInfo = await UserInformationDao.getUserInformationByUserId(this.userID);
      if (newInfo) {
        this.userPhone = newInfo.phone;
        this.userEmail = newInfo.email;
        this.userGender = newInfo.gender;
        this.userCreated_at = newInfo.created_at;
        this.userUpdated_at = newInfo.updated_at;
      }
    } else {
      // 已存在则直接填充属性
      this.userPhone = info.phone;
      this.userEmail = info.email;
      this.userGender = info.gender;
      this.userCreated_at = info.created_at;
      this.userUpdated_at = info.updated_at;
    }
  }

  async changeUserData(changeColumn: string, value: string): Promise<boolean> {
    if ( this.userID < 0) {
      console.error('userID 未初始化');
      return false;
    }
    // 检查列名
    const allowedCols = ['phone', 'email', 'gender'];
    if (!allowedCols.includes(changeColumn)) {
      console.error('修改字段不合法');
      return false;
    }
    // 拼出更新对象
    let fields: UserInformationFields = {};
    console.log('enter change column:'+changeColumn);
    if (changeColumn === 'phone') fields.phone = value;
    if (changeColumn === 'email') fields.email = value;
    if (changeColumn === 'gender') fields.gender = value;
    // 调用更新（返回影响行数>0即成功）
    const res = await UserInformationDao.updateUserInformation(this.userID, fields);
    console.log('res num:'+res)
    if (res > 0) {
      await this.getUserData(); // 更新后填充最新信息
      return true;
    }
    return false;
  }


  build() {
    NavDestination(){
      List({space:12,initialIndex:0}){
        ListItem(){
          Row(){
            Image($r("app.media.Person"))
              .margin({left:'2%',right:'3%'})
              .width(60)
              .invert(0)
            Text(this.name)
              .margin({left:'2%'})
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .padding({ left: 15, top: 15, bottom: 15 })
          .backgroundColor(Color.White)
        }
        .width('100%')
        ForEach(this.listArray,(item:string)=>{
          ListItem() {
            Row() {

              Column() {
                Text(this.dictionChange(item).x)
                  .fontSize(16)
                  .margin({ bottom: 5 })
                Text(this.dictionChange(item).y)
                  .fontSize(16)
                  .margin({ bottom: 5 })
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              if(item ==='userPhone'||item ==='userEmail'||item ==='userGender')
              {
                Row()
                  .width(12)
                  .height(12)
                  .margin({ right: 15 })
                  .border({
                    width: { top: 2, right: 2 },
                    color: 0xcccccc
                  })
                  .rotate({ angle: 45 })
              }
            }
            .borderRadius(15)
            .shadow({ radius: 100, color: '#ededed' })
            .width('90%')
            .alignItems(VerticalAlign.Center)
            .padding({ left: 15, top: 15, bottom: 15 })
            .backgroundColor(Color.White)
          }
          .width('100%')
          .onClick(() => {
            if(item ==='userPhone'||item ==='userEmail'||item ==='userGender'){

              switch(item) {
                case 'userPhone':
                  this.origValue = this.userPhone;
                  this.changeColumn = 'phone';
                  break;
                case 'userEmail':
                  this.origValue = this.userEmail;
                  this.changeColumn = 'email';
                  break;
                case 'userGender':
                  this.origValue = this.userGender;
                  this.changeColumn = 'gender';
                  break;
              }


              this.dialogController.open();

            }
          })
        },(item:string):string=>item)



      }


    }
    .onReady((contextNav:NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
      this.getUserData();

    })
    .title('个人主页')
  }
}