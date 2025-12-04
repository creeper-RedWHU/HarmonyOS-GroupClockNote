import webview from '@ohos.web.webview';
import { common, featureAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

@Entry
@Component
struct Index {
  @State title: string = '注册';
  @State userName: string = '';
  @State userPassword: string = '';

  build() {
    List() {
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

        }.margin('3%')

      }

      ListItem() {
        Row() {
          Image($r("app.media.lock"))
            .width("10%")

          TextInput({ placeholder: '请输入密码' })
            .onChange((value: string) => {
              this.userName = value;
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
            this.title = (this.title === '注册') ? '登录' : '注册';
          })
          .decoration({ type: TextDecorationType.Underline, color: Color.Black })


      }

      ListItem() {
        Button('确认' + this.title, { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(8)
          .backgroundColor(0x317aff)
          .margin({ left: '25%', top: '5%', bottom: '5%' })
          .width('50%')
          .onClick(()=>{
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
