import {DayWorks} from './Entities/DayWorks'
import {CJCalendar } from 'cjcalendar'

class  FontWithBG{
  fontColor:string;
  BGColor:string;
  constructor(fontcolor:string,bgcolor:string) {
    this.fontColor=fontcolor;
    this.BGColor=bgcolor;
  }
}

@Component
export struct HomePage {
  pathInfos: NavPathStack = new NavPathStack();
  @State dayToDoArray:Array<DayWorks>=new Array<DayWorks>();
  @State dateArray:Array<Date>=new Array<Date>();
  name:string = '';
  addDays = (date: Date, days: number): Date => {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  };//console.log(addDays(new Date(), 3)); // 2024-07-11
  @State colorList:Array<FontWithBG>=new Array<FontWithBG>();

  @State choiceDate:Date=new Date();

  normalBGColor:string='#018f8f';
  normalFontColor:string='#f7fbfb';
  todayFontColor:string='#ffffff';
  todayBGColor:string='#32bdc0';
  choiceFontColor:string='#40a9a6';
  choiceBGColor:string='#c6e2e5';
  dictionNumToWeek:Record<number,string>={
    0:'周日',
    1:'周一',
    2:'周二',
    3:'周三',
    4:'周四',
    5:'周五',
    6:'周六',
  }
  equalDay(date1:Date,date2:Date):boolean{
    const year1 = date1.getFullYear();
    const month1 = (date1.getMonth() + 1).toString().padStart(2, '0');
    const day1 = date1.getDate().toString().padStart(2, '0');
    const year2 = date2.getFullYear();
    const month2 = (date2.getMonth() + 1).toString().padStart(2, '0');
    const day2 = date2.getDate().toString().padStart(2, '0');
    return year1===year2 && month1===month2 && day1===day2;
  }

  formatTimestamp(date:Date) {
    const dater = new Date();
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    const second = date.getSeconds().toString().padStart(2, '0');
    return `${year}-${month}-${day} ${hour}:${minute}:${second}`;
  }

  //初始化算法：获取当前日期，然后添加对应星期，
  init():void{
    let date = new Date();
    this.choiceDate=date;
    let dayOfWeek=date.getDay();
    while(this.dateArray.length>0)this.dateArray.pop();
    while(this.colorList.length>0)this.colorList.pop();
    for(let i=0;i<7;i++){
      this.dateArray.push(this.addDays(date,i-dayOfWeek));
      this.colorList.push(
        new FontWithBG(this.equalDay(new Date(),this.dateArray[i])?this.choiceFontColor:this.normalFontColor,
                       this.equalDay(new Date(),this.dateArray[i])?this.choiceBGColor:this.normalBGColor)
      )
    }
    for(let i=0;i<7;i++){
      console.log(this.formatTimestamp(this.dateArray[i]))
    }
  }

  getDayToDoArray():void{

  }

  build() {
    NavDestination(){
      List({ space: 12, initialIndex: 0 }){
        ListItem(){
          //画图 曲线

        }
        ListItem(){
          List(){
            //星期
            ForEach(this.dateArray,(item:Date)=>{
              ListItem(){
                  Text(`${ this.dictionNumToWeek[item.getDay()] }`)
              }.width('14.2%').padding({left:'3%',right:"3%"})

            })
          }.listDirection(Axis.Horizontal)
        }.width('100%')
        ListItem(){
          //数字
          List(){
            ForEach(this.dateArray,(item:Date)=>{
              ListItem(){
                Text(`${ item.getDate().toString().padStart(2, '0') }`)
                  .fontColor(this.colorList[this.dateArray.indexOf(item)].fontColor)
                  .fontSize(20)
                  .height(30)
              }
              .width('14.2%')
              .padding({left:'3%',right:"3%"})
              .borderRadius(30)
              .backgroundColor(
                this.colorList[this.dateArray.indexOf(item)].BGColor
              )
              .onClick(()=>{
                let index:number=0;
                for(let i=0;i<7;i++){
                  if(this.equalDay(this.choiceDate,this.dateArray[i])){
                    index=i;break;
                  }
                }
                console.log("before index:"+index)
                console.log("before fontcolor:"+this.colorList[index].fontColor);
                console.log("before bgcolor:"+this.colorList[index].BGColor);

                if(this.equalDay(new Date(),this.choiceDate)){
                  this.colorList[index].fontColor=this.todayFontColor;//此处崩溃
                  this.colorList[index].BGColor=this.todayBGColor;
                }else{
                  this.colorList[index].fontColor=this.normalFontColor;
                  this.colorList[index].BGColor=this.normalBGColor;
                }
                console.log("after index:"+index)
                console.log("after fontcolor:"+this.colorList[index].fontColor);
                console.log("after bgcolor:"+this.colorList[index].BGColor);
                this.choiceDate=item;
                for(let i=0;i<7;i++){
                  if(this.equalDay(this.choiceDate,this.dateArray[i])){
                    index=i;break;
                  }
                }
                console.log("before index:"+index)
                console.log("before fontcolor:"+this.colorList[index].fontColor);
                console.log("before bgcolor:"+this.colorList[index].BGColor);
                this.colorList[index].fontColor=this.choiceFontColor;
                this.colorList[index].BGColor=this.choiceBGColor;
                console.log("after index:"+index)
                console.log("after fontcolor:"+this.colorList[index].fontColor);
                console.log("after bgcolor:"+this.colorList[index].BGColor);
                console.log('切换：'+this.formatTimestamp(item));
                this.colorList = [ ...this.colorList ];

              })

            })
          }.listDirection(Axis.Horizontal)
        }
      }
      .backgroundColor(this.normalBGColor)


    }.onReady((contextNav:NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
    })
    .title('首页-Todo清单',{backgroundColor:this.normalBGColor})
    .onClick(()=>{
    })
    .onWillShow(()=>{
      this.init()
    })

  }
}