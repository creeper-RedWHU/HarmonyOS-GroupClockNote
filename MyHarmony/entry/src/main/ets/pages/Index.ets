import webview from '@ohos.web.webview';
import { common, featureAbility, UIAbility, Want } from '@kit.AbilityKit';
import { router, Router } from '@kit.ArkUI';
import relationalStore from '@ohos.data.relationalStore';
import {UserDao} from './database';
import {PasswordUtil} from './database';
import {printDebug} from './printDebug';
import { User } from './Entities/User';

const DOMAIN = 0x0000;

interface GeneratedObjectLiteralInterface_1 {
  name: string;
  securityLevel: relationalStore.SecurityLevel;
}

@Entry
@Component
struct Index {
  @State userID:number=0;
  @State title: string = '注册';
  @State userName: string = '';
  @State userPassword: string = '';
  @State buttonWord:string='确认'+this.title;
  encryptUtil=new PasswordUtil();
  want:Want = {
    deviceId:'',
    bundleName:'com.example.myharmony',
    abilityName:'FirstPageAbility'
  }
  Context =this.getUIContext().getHostContext() as common.UIAbilityContext;
  UIContext= this.getUIContext();

  jump(username:string|null=null):void{
    router.pushUrl({
      url:'pages/FirstPage',
      params:{userName:this.userName,userID:this.userID}
    },router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`跳转失败, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('跳转成功');
    })
  }

  async validation(): Promise<boolean>{

    let username_encrypted= this.encryptUtil.hashPassword(this.userName);
    let password_encrypted=this.encryptUtil.hashPassword(this.userPassword);
    if(this.title === '注册'){
      console.log('enter');
      let x=await UserDao.getUserByName(username_encrypted);
      if(x.id === -1){
        console.log('enter2');
        this.userID =await UserDao.registerUser(username_encrypted,password_encrypted)
        return true;
      }return false;
    }else{
      if(await UserDao.getUserByName(username_encrypted) === null){
        return false;
      }
      let user=await UserDao.getUserByName(username_encrypted);
      if(user.id ===-1)return false;
      this.userID=user.id;
      return true;
    }
  }

  build() {
    List() {
      ListItem(){
        Button('调试')
          .onClick(()=>{
            this.jump('测试用户');
          })
      }
      ListItem() {
        Text(this.title)
          .fontSize(50)
          .margin('5%')
          .fontColor(Color.Black)

      }

      ListItem() {
        Row() {
          Image($r("app.media.email"))
            .width('10%')
          TextInput({ placeholder: '请输入账号' })
            .onChange((value: string) => {
              this.userName = value;
            })
            .borderRadius(0)

        }.margin('3%')

      }

      ListItem() {
        Row() {
          Image($r("app.media.lock"))
            .width("10%")

          TextInput({ placeholder: '请输入密码' })
            .onChange((value: string) => {
              this.userPassword = value;
            })
            .borderRadius(0)
        }
        .margin('3%')

      }

      ListItem() {
        Text(this.title === '注册' ? '已有帐号？立即登录' : '没有账号？现在注册')
          .fontSize(10)
          .margin('3%')
          .onClick(() => {
            console.log('hello');
            this.title = (this.title === '注册') ? '登录' : '注册';
            this.buttonWord='确认'+this.title;
          })
          .decoration({ type: TextDecorationType.Underline, color: Color.Black })


      }

      ListItem() {
        Button(this.buttonWord, { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(8)
          .backgroundColor(0x317aff)
          .margin({ left: '25%', top: '5%', bottom: '5%' })
          .width('50%')
          .onClick(async ()=>{
            let x= await this.validation();
            if(x === true){
              let titleWord:string="";
              let messageWord:string="";
              if(this.title === '注册'){
                titleWord='注册成功';
                messageWord='请牢记用户名和密码';
              }else{
                titleWord='登陆成功';
                messageWord='欢迎'+this.userName+'用户';
              }
              this.UIContext.showAlertDialog(
                {
                  title: titleWord,
                  message: messageWord,
                  autoCancel: true,
                  alignment: DialogAlignment.Center,
                  gridCount: 3,
                  confirm: {
                    value: '确认',
                    action: () => {
                      // this.Context.startAbility(this.want).then(()=>{
                      //   console.log("Start ability success");
                      // }).catch((err:string)=>{
                      //   console.error("Start ability failed: " + err);
                      // });
                      this.jump();
                    }
                  },
                  cancel: () => {}
                }
              )


            }else{
              let titleWord:string="";
              let messageWord:string="";
              if(this.title === '注册'){
                titleWord='注册失败';
                messageWord='请确认不包含特殊字符或更改用户名后重试';
              }else{
                titleWord='登陆失败';
                messageWord='用户名或密码输入错误';
              }
              this.UIContext.showAlertDialog(
                {
                  title: titleWord,
                  message: messageWord,
                  autoCancel: true,
                  alignment: DialogAlignment.Center,
                  gridCount: 3,
                  confirm: {
                    value: '确认',
                    action: () => {}
                  },
                  cancel: () => {}
                }
              )
            }
          })


      }

      ListItem() {
        Image($r('app.media.pic'))
      }

    }.listDirection(Axis.Vertical)
    .align(Alignment.Center)
    .margin({ left: '10%', top: '10%', right: "10%" })



  }
}


// struct Index {
//   Context =this.getUIContext().getHostContext() as common.UIAbilityContext;
//   webviewController:webview.WebviewController = new webview.WebviewController();
//   want:Want = {
//     deviceId:'',
//     bundleName:'com.example.myharmony',
//     abilityName:'FirstPageAbility'
//   }
//   startAbilityTest(): void {
//     hilog.info(DOMAIN, 'testTag', '%{public}s', 'enter');
//     this.Context.startAbility(this.want);
//   }
//   build() {
//     Column(){
//       Button('click me')
//         .onClick(()=>{
//           hilog.info(DOMAIN, 'testTag', '%{public}s', 'onclick');
//           this.startAbilityTest();
//         })
//     }
//
//   }
//
// }
