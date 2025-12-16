import {DayWorks} from './Entities/DayWorks'
import {CJCalendar } from 'cjcalendar'
import { Work } from './Entities/Work';
import { MatterInformationDao } from './database';
import { ExpandMode } from '@kit.ArkUI';

class  FontWithBG{
  fontColor:string;
  BGColor:string;
  constructor(fontcolor:string,bgcolor:string) {
    this.fontColor=fontcolor;
    this.BGColor=bgcolor;
  }
}

@CustomDialog
export struct HomePageAddDialog{
  cancel: () => void = () => {
  }
  confirm: (x:string,y:string) => void = (x:string,y:string) => {
  }
  controller: CustomDialogController;
  columnName:string='';
  @State updateStringContent:string='';
  @State updateStringCategory:string='';


  build() {
    Column() {
      Text('新增事务').fontSize(20).margin({ top: 10, bottom: 10 })
      Row(){
        Text('待办内容')
        TextInput({ placeholder: '请输入待办内容' })
          .onChange((value: string) => {
            this.updateStringContent = value;
          })
      }.padding(20)
      Row(){
        Text('待办分类')
        TextInput({ placeholder: '请输入待办分类' })
          .onChange((value: string) => {
            this.updateStringCategory = value;
          })
      }.padding(20)
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            this.controller.close();
            if (this.cancel) {
              this.cancel();
            }
          }).backgroundColor(0xffffff).fontColor(Color.Red)
        Button('确认')
          .onClick(() => {
            this.controller.close();
            if (this.confirm) {

              this.confirm(this.updateStringContent,this.updateStringCategory);
            }
          }).backgroundColor(0xffffff).fontColor(Color.Blue)
      }.margin({ bottom: 10 })
    }
  }
}

@Component
export struct HomePage {
  pathInfos: NavPathStack = new NavPathStack();
  // @State dayToDoArray:Array<DayWorks>=new Array<DayWorks>();
  @State dayToDoArray:Array<DayWorks>=new Array<DayWorks>();
  @State dateArray:Array<Date>=new Array<Date>();
  name:string = '';
  userID:number=0;
  addDays = (date: Date, days: number): Date => {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  };//console.log(addDays(new Date(), 3)); // 2024-07-11
  @State colorList:Array<FontWithBG>=new Array<FontWithBG>();

  @State choiceDate:Date=new Date();

  dialogController: CustomDialogController = new CustomDialogController({
    builder: HomePageAddDialog({
      cancel: ()=> { this.onCancel() },
      confirm:this.onAccept.bind(this)
    }),
  })

  onCancel() {
    console.info('Callback homepage when the first button is clicked');
  }

  async onAccept(x:string,y:string) {
    console.info('Callback homepage when the second button is clicked'+x);
    await this.addSomeWorkToDay(x,y);
    while(this.dayToDoArray.length)this.dayToDoArray.pop();
    for(let i=0;i<7;i++){
      await this.getDayToDoArray(this.dateArray[i]);
    }
    this.dayToDoArray=[...this.dayToDoArray];
    // await this.changeUserData(this.changeColumn,this.result);
  }


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

  formatTimeStampByYMD(date:Date){
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
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
  async init(): Promise<void>{
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
      await this.getDayToDoArray(this.dateArray[this.dateArray.length-1]);
    }
    for(let i=0;i<7;i++){
      console.log(this.formatTimestamp(this.dateArray[i]))
    }
  }

  async getDayToDoArray(date: Date): Promise<void> {
    let dateString = this.formatTimeStampByYMD(date);
    let works: Work[] = [];
    try {
      const matters = await MatterInformationDao.getMatterByUserIdAndDate(this.userID, dateString);
      for (const matter of matters) {
        // category 如为数字用 Number，字符串则直接赋值
        const w = new Work(
          matter.id,
          matter.user_id,
          // matter.title, // 你的数据表没有title，就不用
          matter.content,
          matter.category,
          new Date(matter.ascription_time)
        );
        w.completed = matter.finished;
        works.push(w);
      }
      console.log("日期："+dateString+"有"+works.length+"件事被添加");
    } catch (err) {
      console.error('获取事项失败', err);
    }
    this.dayToDoArray.push(new DayWorks(date, works));
  }

  async addSomeWorkToDay(content: string, category: string): Promise<void> {
    let userid = this.userID;
    let timeString = this.formatTimeStampByYMD(this.choiceDate);
    let finished = 0;

    // 调用 MatterInformationDao.addMatter 方法插入
    try {
      await MatterInformationDao.addMatter({
        user_id: userid,
        ascription_time: timeString,
        category: category,
        content: content,
        finished: finished,
        // created_at/updated_at会由DAO自动填充
      });
      console.log("insert 成功!")
      // 可选：插入成功后刷新事项列表或提示
      // await this.refreshDayToDoArray(this.choiceDate); // 如有此方法
      // promptAction({ message: "添加成功" }); // 如用提示
    } catch (err) {
      console.error("添加事项失败:", err);
    }
  }

  build() {
    NavDestination(){
      List({ space: 12, initialIndex: 0 }){
        ListItem(){
          //画图 曲线
          List(){
            //星期
            ForEach(this.dayToDoArray,(item:DayWorks)=>{
              ListItem(){
                Text(`${ item.arrays.length }`)
              }.width('14.2%').padding({left:'3%',right:"3%"})

            })
          }.listDirection(Axis.Horizontal)
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
      List(){
        ForEach(this.dayToDoArray,(item:DayWorks)=>{
          if(this.equalDay(item.day,this.choiceDate)){
            if(item.arrays.length){
              ForEach(item.arrays,(item_a:Work)=>{
                ListItem(){
                  Row(){
                    Toggle({ type: ToggleType.Checkbox, isOn: item_a.completed === 1 })
                      .onChange(async (isOn: boolean) => {
                        const newFinished = isOn ? 1 : 0;
                        try {
                          const res = await MatterInformationDao.updateMatterById(item_a.work_id, { finished: newFinished });
                          if (res > 0) {
                            item_a.completed = newFinished; // 若有本地状态同步
                            // 如有需要可反馈或刷新页面
                          }
                        } catch (err) {
                          console.error('更新事项完成状态失败', err);
                        }
                      })
                    Text(`${item_a.description}`)
                      .fontWeight(FontWeight.Bold)
                      .width('80%')
                      .fontSize(20)

                    Text(`${item_a.category}`)
                      .fontColor(Color.Orange)
                      .textAlign(TextAlign.End)
                      .fontSize(15)
                  }
                  .padding({left:'10%',bottom:5,top:5})
                }
              })
            }else{
              ListItem(){
                Text('今天没有设置待办！')
                  .fontColor(Color.Gray)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
              }.padding({top:20,bottom:20,left:'10%',right:'10%'})
            }

          }
        })
      }
      .height('80%')
      Column({space:'center'}){
        Image($r('app.media.plus'))
          .width("15%")
          .onClick(()=>{
            this.dialogController.open();
          })
      }

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