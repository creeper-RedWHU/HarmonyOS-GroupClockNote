import { CellStatus, CJCalendar,
  CJCalendarControl,
  CJCalStatusParams, CJCellStyle, CJDateItem, OptMode } from 'cjcalendar'
import { MatterInformationDao } from './database';
import { DayWorks } from './Entities/DayWorks';
import { Work } from './Entities/Work';


@Component
export struct CalendarPage{
  pathInfos:NavPathStack=new NavPathStack();
  name:string='';

  cjDataItem: CJDateItem = new CJDateItem(new Date())
  @State message: string = 'Hello World';
  userID:number=0;
  cjCellStyle: CJCellStyle = new CJCellStyle()
  cjCalStatus: CJCalStatusParams = new CJCalStatusParams()
  cjCellStatus:  CellStatus = new CellStatus()
  controller: CJCalendarControl = new CJCalendarControl()
  @State defSelectedItems: Array<string> = ["2024-11-03", "2024-11-08"]
  @State extras: Record<string, number | string | boolean> = {}
  @State rcdList:Array<DayWorks>=new Array<DayWorks>();

  addDays = (date: Date, days: number): Date => {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  };
  // 测试刷新
  @State test: string = "xx"
  @Builder
  BuildCellBackground() {
    if (this.cjDataItem.isSelected) {
      Column()
        .alignItems(HorizontalAlign.End)
        .justifyContent(FlexAlign.Start)// .backgroundColor(this.cjDataItem.extras.test == '1' ? Color.Orange : this.cjCellStatus.backgroundColor)
        .width(50)
        .height(130)
        .border({
          width: 1,
          color: "#03A9F4"
        })
        .borderRadius(6)
        .backgroundColor("#03A9F4")
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
          matter. content,
          matter.category,
          new Date(matter.ascription_time)
        );
        w.completed = matter.finished;
        works.push(w);
      }
      console. log("日期："+dateString+"有"+works.length+"件事被添加");
    } catch (err) {
      console.error('获取事项失败', err);
    }
    this.rcdList.push(new DayWorks(date, works));

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
  formatTimeStampByYMD(date: Date){
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  @Builder
  buildCellBody(){
    Column() {

      Text(this.cjDataItem.date +'')
        .fontColor(this.cjDataItem.isPre || this.cjDataItem.isNext
          ? Color. Gray
          : this.cjDataItem.isSelected
            ?  Color.White
            : this. cjDataItem.isToday?
            this.cjCellStatus.fontColor:
            Color.Green
        )
        .fontSize(this.cjCellStyle.fontSize)
        .fontWeight(this.cjCellStyle.fontFontWeight)
      // Text(`${this.cjDataItem.fullYear}年${this.cjDataItem.month+1}月${this.cjDataItem.date}日''`)
      //   .fontColor(this.cjDataItem.isPre || this.cjDataItem.isNext
      //     ? Color.Gray
      //     : this.cjDataItem.isSelected
      //       ? Color.White
      //       : this.cjDataItem. isToday?
      //       this.cjCellStatus. fontColor:
      //         Color.Green
      //     )
      //   .fontSize(this. cjCellStyle.fontSize)
      //   .fontWeight(this.cjCellStyle. fontFontWeight)

      // 可以加备注之类的自定义信息
      // Text('halloooooooooooooooooooooooooooo')
      //   .fontSize(10)
      //   .fontColor(Color.Gray)
      //   .fontColor(this.cjCellStatus. fontColor)

      // if(this.rcdList[this. formatTimeStampByYMD(new Date(
      //   this.cjDataItem.fullYear,
      //   this. cjDataItem.month,
      //   this.cjDataItem.date
      // ))]){
      //   ForEach(this.rcdList[this.formatTimeStampByYMD(new Date(
      //     this.cjDataItem. fullYear,
      //     this.cjDataItem.month+1,
      //     this. cjDataItem.date
      //   ))],(item:Work)=>{
      //     Text(item.description)
      //       .fontColor(Color.Black)
      //       .fontSize(10)
      //       .textAlign(TextAlign.Center)
      //       .backgroundColor(Color. Gray)
      //   })
      // }


      //========add start========
      // 从 extras 中获取该日期的工作列表并显示
      if(this.cjDataItem. extras.works) {
        ForEach(this.cjDataItem.extras. works as Work[], (work: Work) => {
          Text(work.description)
            .fontColor(Color.White)
            .fontSize(9)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: 2, right: 2 })
            .margin({ top: 2 })
            .borderRadius(3)
            .backgroundColor(work. completed ? '#9E9E9E' : '#FF6B6B')
        })
      }
      //========add end========

      ForEach(this.rcdList,(item:DayWorks)=>{
        if(this. equalDay(item.day,new Date(
          this.cjDataItem.fullYear,this. cjDataItem.month,this.cjDataItem.date
        ))){
          Text('success')
        }
      })

    }
    .alignItems(HorizontalAlign.Center)
    .padding(5)
  }

  build() {
    NavDestination(){
      // Text('hello from CalendarPage')
      CJCalendar({
        fastTodayFontColor: "#ffffff",
        // themeColor:"#E64A19",
        rcdList:this.rcdList,
        controller:this.controller,
        optMode: OptMode.SINGLE,
        isShowFoldView:  false,
        extras:this. extras,
        itemCellHeight:130,
        showLunar:true,
        onlyShowDateArea: true,
        buildCellBody:this.buildCellBody,
        buildCellBackground:this.BuildCellBackground,

        buildCellStyle:(item:CJDateItem)=>{
          let cjCellStyle: CJCellStyle = new CJCellStyle()
          cjCellStyle. borderWidth=1
          cjCellStyle.borderRadius=1

          return cjCellStyle
        },
        onMonthChangeBefore:()=>{

        },
        //========add start========
        // 使用 reBuildCellItem 将工作数据注入到每个日期单元格的 extras 中
        reBuildCellItem: (cjDateItem: CJDateItem) => {
          // 查找该日期对应的工作列表
          const dayWork = this.rcdList. find(item =>
          this. equalDay(item.day, new Date(
            cjDateItem.fullYear,
            cjDateItem.month,
            cjDateItem.date
          ))
          );

          // 如果找到该日期的工作列表，将其存储到 extras 中
          if (dayWork && dayWork.arrays. length > 0) {
            cjDateItem.extras. works = dayWork.arrays;
          }
        }
        //========add end========
      });


    }
    .onReady((contextNav:NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
    })
    .onWillShow(async ()=>{
      console.log(`${this.cjDataItem.month}月${this. cjDataItem.date}日`)
      let dateToday=new Date(this.cjDataItem.fullYear,this.cjDataItem.month);
      console.log(this.formatTimeStampByYMD(dateToday))
      let delta = 1;

      //========add start========
      // 清空旧数据
      this.rcdList = [];
      //========add end========

      while(true){
        let oldMonth=dateToday.getMonth();
        await this.getDayToDoArray(dateToday);
        dateToday=this.addDays(dateToday,delta);
        if(oldMonth!=dateToday. getMonth()){
          break;
        }
      }

      //========add start========
      // 数据加载完成后刷新日历，触发 reBuildCellItem
      console.log(`数据加载完成，共 ${this.rcdList.length} 天`);
      this.controller.refresh(true);
      //========add end========

    })
  }
}