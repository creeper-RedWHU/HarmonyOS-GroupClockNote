import { it } from '@ohos/hypium';
import { Button } from '@ohos.multimodalInput.mouseEvent';
import {HomePage} from './homepage'
import {CalendarPage} from './Calendar'
import {Clock} from './Clock'
import {Analyse} from './Analyse'
import {Person} from './Person'
import { router } from '@kit.ArkUI';

@Entry
@Component
struct  FistPage{
  //=====UserData=====
  params = router.getParams() as Record<string, Object>;
  @State userID:number=this.params['userID'] as number;
  @State userName: string = this.params['userName'] as string;
  //=====UserData=====

  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  private listArray: Array<string> = ['HOMEPAGE', 'Calendar', 'Clock', 'Analyse','Person'];
  private diction:Record<string,string>={
    'HOMEPAGE':'首页',
    'Calendar':'专注日历',
    'Clock':'专注时钟',
    'Analyse':'专注分析',
    'Person':'个人主页'
  }

  jump():void{
    router.pushUrl({
      url:'pages/Index'
    },router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`跳转失败, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('跳转成功');
    })
  }
  @State choiceString:string='';
  @Builder
  PageMap(pageName: string) {
    if (pageName === 'HOMEPAGE') {
      HomePage({name:pageName});
    }else if(pageName === 'Calendar'){
      CalendarPage({name:pageName});
    }else if(pageName === 'Clock'){
      Clock({name:pageName});
    }else if(pageName === 'Analyse'){
      Analyse({name:pageName});
    }else if(pageName === 'Person'){
      Person({name:this.userName,userID:this.userID});
    }

  }

  build() {
    Navigation(this.pathInfos){
      List(){
        ListItem(){
            Text('欢迎您，'+this.userName+'!')
              .fontWeight(FontWeight.Bold)
              .fontSize(30)
              .onClick(()=>{
                this.jump();
              })
        }
        .margin({bottom:'15%',left:'5%'})
        ListItem(){
          //包裹菜单悬浮件
          List({ space: 12, initialIndex: 0 }) {
            ForEach(this.listArray,(item:string)=>{
              ListItem() {
                Row() {
                  Row() {
                    Image($r("app.media."+item))
                      .margin({left:'2%',right:'3%'})
                      .width('85%')
                      .invert(0)
                  }
                  // .backgroundColor(Color.Red)
                  .width(30)
                  .height(30)
                  .backgroundColor('#a8a8a8')
                  .margin({ right: 20 })
                  .borderRadius(20)
                  .justifyContent(FlexAlign.Center)

                  Column() {
                    Text(this.diction[item])
                      .fontSize(16)
                      .margin({ bottom: 5 })
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

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
                .borderRadius(15)
                .shadow({ radius: 100, color: '#ededed' })
                .width('90%')
                .alignItems(VerticalAlign.Center)
                .padding({ left: 15, top: 15, bottom: 15 })
                .backgroundColor(Color.White)
              }
              .width('100%')
              .onClick(() => {
                this.pathInfos.pushPathByName(`${item}`, '详情页面参数')//将name指定的NaviDestination页面信息入栈,传递的参数为param
              })

                // .onClick(()=>{
                //   this.choiceString=item;
                //   this.pathInfos.pop();
                //   this.pathInfos.pushPathByName(`${item}`,'cans');
                //   console.log('enter:'+item);
                // })
            },(item:string):string=>item)

          }
        }

      }.listDirection(Axis.Vertical)
      .align(Alignment.Center)
      .edgeEffect(EdgeEffect.Spring)
      .sticky(StickyStyle.Header)
      .chainAnimation(false)
      }
    .navDestination(this.PageMap)
    .mode(NavigationMode.Auto)
  }
}

