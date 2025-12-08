import { it } from '@ohos/hypium';
import { Button } from '@ohos.multimodalInput.mouseEvent';
import {HomePage} from './homepage'
import {CalendarPage} from './Calendar'
import {Clock} from './Clock'
import {Analyse} from './Analyse'
import {Person} from './Person'

@Entry
@Component
struct  FistPage{
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  private listArray: Array<string> = ['HOMEPAGE', 'Calendar', 'Clock', 'Analyse','Person'];

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
      Person({name:pageName});
    }

  }

  build() {
    List(){
      ListItem(){
        //包裹页面跳转

        Navigation(this.pathInfos){
          Text('hello from firstpage');
        }
        .navDestination(this.PageMap)
        .mode(NavigationMode.Auto)

      }.height('90%')
      ListItem(){
        //包裹菜单悬浮件
        Row(){
          ForEach(this.listArray,(item:string)=>{
            if(item === this.choiceString)
            Image($r("app.media."+item))
              .width('13%')
              .margin({left:'2%',right:'3%'})
              .invert(1)
              .onClick(()=>{
                this.choiceString=item;
                this.pathInfos.pop();
                console.log('before'+`${this.pathInfos.size()}`)
                this.pathInfos.pushPathByName(`${item}`,'cans');
                console.log(`${this.pathInfos.size()}`)
                console.log('enter:'+item);
              })
            else Image($r("app.media."+item))
              .width('13%')
              .margin({left:'2%',right:'3%'})
              .invert(0)
              .onClick(()=>{
                this.choiceString=item;
                this.pathInfos.pop();
                this.pathInfos.pushPathByName(`${item}`,'cans');
                console.log('enter:'+item);
              })
          },(item:string):string=>item)
        }
      }
      .borderColor(Color.Gray)
      .borderWidth(1)
      .height('10%')
      .width('100%')
    }.listDirection(Axis.Vertical)
    .align(Alignment.Center)
    .edgeEffect(EdgeEffect.Spring)
    .sticky(StickyStyle.Header)
    .chainAnimation(false)

  }
}

