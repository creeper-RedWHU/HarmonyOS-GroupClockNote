import { text } from "@kit.ArkGraphics2D";
import { AlphabetIndexerModifier } from "@kit.ArkUI";
import { UICountdown, Controller } from '@hw-agconnect/ui-countdown';
//========add start========
import { FocusRecord } from './Entities/RecordOFocus';
import { FocusRecordDao } from './database'
import { promptAction } from '@kit.ArkUI';
//========add end========

//========add start========
// 自定义倒计时输入对话框
@CustomDialog
struct TimeInputDialog {
  controller: CustomDialogController
  cancel: () => void = () => {}
  confirm: (minute: number, second: number) => void = () => {}
  @State inputMinute: string = '25'
  @State inputSecond: string = '0'

  // 限制输入范围 0-59
  validateInput(value: string): number {
    let num = parseInt(value) || 0
    if (num < 0) num = 0
    if (num >= 60) num = 59
    return num
  }

  build() {
    Column({ space: 20 }) {
      Text('设置专注时长')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Row({ space: 10 }) {
        Column() {
          Text('分钟')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 5 })
          TextInput({ placeholder: '0-59', text: this.inputMinute })
            .type(InputType.Number)
            .maxLength(2)
            .width(100)
            .onChange((value:  string) => {
              this. inputMinute = value
            })
        }

        Column() {
          Text('秒')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 5 })
          TextInput({ placeholder: '0-59', text: this.inputSecond })
            .type(InputType.Number)
            .maxLength(2)
            .width(100)
            .onChange((value: string) => {
              this.inputSecond = value
            })
        }
      }
      .justifyContent(FlexAlign.Center)

      Text('(分钟和秒数均不超过59)')
        .fontSize(12)
        .fontColor('#999999')

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
            this.cancel()
          })
          .backgroundColor('#f0f0f0')
          .fontColor('#333333')
          .width(120)

        Button('确定')
          .onClick(() => {
            const minute = this.validateInput(this.inputMinute)
            const second = this.validateInput(this.inputSecond)

            // 至少要有1秒
            if (minute === 0 && second === 0) {
              promptAction.showToast({
                message: '时长至少为1秒',
                duration:  2000
              })
              return
            }

            this.controller.close()
            this.confirm(minute, second)
          })
          .backgroundColor('#018f8f')
          .fontColor(Color.White)
          .width(120)
      }
      .width('100%')
    }
    .padding(20)
  }
}
//========add end========

@Component
export struct Clock{
  pathInfos:  NavPathStack=new NavPathStack();
  name: string='';
  userID: number=0;
  userName: string='';
  normalBGColor:  string='#018f8f';
  normalFontColor: string='#f7fbfb';
  todayFontColor:   string='#ffffff';
  todayBGColor:  string='#32bdc0';
  choiceFontColor: string='#40a9a6';
  choiceBGColor: string='#c6e2e5';

  private controller=new Controller();
  beginText:  string="▶ 开始专注"
  endText: string="⏸ 放弃专注"
  beginColor: string="#1596b6";
  endColor:  string="#d01b39";
  beginTimeFontColor: string='#808080';
  endTimeFontColor:string='#10aab0';

  //========add start========
  @State setMinute: number = 0  // 分钟
  @State setSecond: number = 0   // 秒
  //========add end========

  @State buttonColor: string=this.beginColor;
  @State start: boolean=false;
  @State textToShow:string=this.  beginText;
  @State timeFontColor:string=this.  beginTimeFontColor;
  @State animationId: number | null = null
  @State progressValue: number = 100

  beginTime:Date=new Date();
  endTime:Date = new Date();

  //========add start========
  // 专注记录列表（显示已完成和未完成的）
  @State focusRecords: FocusRecord[] = [];

  // 倒计时输入对话框控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: TimeInputDialog({
      cancel: () => { this.onDialogCancel() },
      confirm: (minute: number, second:  number) => { this.onDialogConfirm(minute, second) }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  onDialogCancel() {
    console.info('用户取消了时间设置')
  }

  onDialogConfirm(minute: number, second:  number) {
    console.info(`用户设置时长:  ${minute}分${second}秒`)
    this.setMinute = minute
    this.setSecond = second
    this. totalSeconds = minute * 60 + second

    // 开始专注
    this.startFocus()
  }
  //========add end========

  formatTimestamp(date: Date) {
    const year = date.  getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.  getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    const second = date.getSeconds().toString().padStart(2, '0');
    return `${year}-${month}-${day} ${hour}: ${minute}:${second}`;
  }

  //========add start========
  // 格式化时间显示（只显示时分秒）
  formatTimeOnly(dateStr:   string): string {
    return dateStr.substring(11);
  }

  // 格式化日期显示（只显示年月日）
  formatDateOnly(dateStr: string): string {
    return dateStr.substring(0,10);
  }

  // 加载专注记录（加载已完成和未完成的记录）
  async loadFocusRecords() {
    try {
      // 获取所有记录
      this.focusRecords = await FocusRecordDao.getFocusRecordByUserId(this.userID);
      console.log(`加载了 ${this.focusRecords. length} 条专注记录`);
    } catch (err) {
      console.error('加载专注记录失败', err);
    }
  }

  // 保存专注记录（completed:  1=完成, 0=未完成）
  async saveFocusRecord(completed: number) {
    try {
      const beginTimeStr = this.formatTimestamp(this.beginTime);
      const endTimeStr = this.formatTimestamp(this.endTime);
      const duration = Math.floor((this.endTime. getTime() - this.beginTime.getTime()) / 1000);
      if(duration === 0)return;
      await FocusRecordDao.addFocusRecord({
        user_id: this.userID,
        begin_time: beginTimeStr,
        end_time:  endTimeStr,
        duration:  duration,
        completed: completed
      });

      console.log(`专注记录保存成功(${completed === 1 ? '已完成' : '未完成'}): ${beginTimeStr} - ${endTimeStr}`);
      // 重新加载记录
      await this.loadFocusRecords();
    } catch (err) {
      console.error('保存专注记录失败', err);
    }
  }

  // 开始专注的逻辑
  startFocus() {
    this.buttonColor = this.endColor;
    this.textToShow = this.endText;
    this.timeFontColor = this.endTimeFontColor;
    this.start = true;
    this.beginTime = new Date();

    // 更新 UICountdown 的时间
    this.controller.update()

    // 开始进度条动画
    if (this.animationId === null) {
      this.animationId = setInterval(() => {
        this.progressValue--
        if (this.progressValue <= 0) {
          // 倒计时结束，自动重置
          clearInterval(this.animationId)
          this.animationId = null
          this.progressValue = 100
          this.start = false
        }
      }, (this.totalSeconds * 1000) / 100)
    }
  }
  //========add end========

  //========add start========
  // 倒计时总时长（秒）
  @State totalSeconds: number = 25 * 60
  //========add end========

  build() {
    NavDestination(){
      Column() {
        Toggle({type: ToggleType.Button, isOn: false}){
          Text(this.textToShow)
            .fontColor(this.normalFontColor)
            .fontSize(30)
            .textAlign(TextAlign.Center)
        }. align(Alignment.Center)
        .padding(20)
        .backgroundColor(this.buttonColor)
        .onClick(() => {
          if(this.buttonColor === this.beginColor) {
            //========add start========
            // 开始专注 - 弹出时间输入对话框
            this. dialogController.open()
            //========add end========
          } else {
            //========add start========
            // 放弃专注 - 保存未完成记录
            this. buttonColor = this.beginColor;
            this.textToShow = this.beginText;
            this.timeFontColor = this. beginTimeFontColor;
            this.start = false;
            this.endTime = new Date();

            // 保存未完成记录
            this.saveFocusRecord(0);

            // 停止进度条动画并重置
            if (this.animationId !== null) {
              clearInterval(this.animationId)
              this.animationId = null
            }
            this. progressValue = 100

            // 重置倒计时
            this. controller.update();
            //========add end========
          }
        })
      }
      .width('100%')
      .height('20%')
      .linearGradient({
        direction: GradientDirection.Top,
        colors: [
          [this.todayBGColor, 0.0],
          [this.normalBGColor, 1.0]
        ]
      })

      Row(){
        UICountdown({
          showDay: false,
          showHour: false,
          minute: `${this.setMinute}`,
          second: `${this.setSecond}`,
          start: this.start,
          controller: this.controller,
          timeColor: this.timeFontColor,
          fontSize: 60,
          timeup: () => {
            // 倒计时结束，停止进度条动画
            if (this.animationId !== null) {
              clearInterval(this. animationId)
              this. animationId = null
            }
            this.progressValue = 100
            this.start = false
            // 重置按钮状态
            this.buttonColor = this.beginColor
            this.textToShow = this.beginText
            this.timeFontColor = this.beginTimeFontColor
            console.log('倒计时结束')
            this.endTime = new Date();

            //========add start========
            // 保存已完成记录
            this.saveFocusRecord(1);
            //========add end========
          }
        })
          .padding('6%')
      }
      .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
      .height('20%')
      .alignItems(VerticalAlign.Center)
      .margin({ left: '15%' })
      .justifyContent(FlexAlign.Center)

      Progress({ value: 0, total: 100, type: ProgressType.Ring })
        .color(this.normalBGColor)
        .value(this.progressValue)
        .width(200)
        .style({
          strokeWidth: 10,
          scaleCount: 20,
          scaleWidth: 5,
          enableSmoothEffect: true
        })
        .backgroundColor(Color.White)
        .rotate({
          x: 0,
          y: 1,
          z: 0,
          centerX: '50%',
          centerY:  '50%',
          angle:  180
        })

      //========add start========
      // 专注记录列表区域（显示已完成和未完成的记录）
      Column() {
        Text(this.userName + '的专注记录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 15 })
          .fontColor(this.choiceFontColor)

        if (this.focusRecords. length === 0) {
          // 空状态提示
          Column() {
            Text('📝')
              .fontSize(48)
              .margin({ bottom: 10 })
            Text('暂无专注记录')
              .fontSize(16)
              .fontColor('#999999')
            Text('完成一次专注后将显示在这里')
              .fontSize(12)
              .fontColor('#CCCCCC')
              .margin({ top: 5 })
          }
          .justifyContent(FlexAlign.Center)
          .height(200)
        } else {
          // 使用 Grid 组件展示记录
          Grid() {
            ForEach(this.focusRecords, (record: FocusRecord, index: number) => {
              GridItem() {
                Column() {
                  // 日期显示
                  Text(this. formatDateOnly(record.begin_time))
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ bottom: 8 })

                  // 时间范围
                  Row() {
                    Text(this.formatTimeOnly(record.begin_time))
                      .fontSize(14)
                      .fontColor(this.normalBGColor)
                      .fontWeight(FontWeight.Medium)
                    Text(' → ')
                      .fontSize(12)
                      .fontColor('#999999')
                    Text(this.formatTimeOnly(record.end_time))
                      .fontSize(14)
                      .fontColor(this.normalBGColor)
                      . fontWeight(FontWeight.Medium)
                  }
                  . justifyContent(FlexAlign. Center)
                  .margin({ bottom: 8 })

                  // 时长显示
                  Text(record.getDurationString())
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(record.isCompleted() ? this.todayBGColor : '#FF9800')
                    .margin({ bottom: 8 })

                  // 完成状态标签
                  Text(record.isCompleted() ? '✓ 已完成' : '○ 未完成')
                    .fontSize(12)
                    .fontColor(Color.White)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(10)
                    .backgroundColor(record.isCompleted() ? this.todayBGColor : '#FF9800')
                }
                .width('100%')
                .padding(15)
                .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                .borderRadius(12)
                .shadow({
                  radius: 8,
                  color: '#1F000000',
                  offsetX:  0,
                  offsetY: 2
                })
              }
              .padding(8)
            })
          }
          .columnsTemplate('1fr 1fr') // 两列布局
          .rowsGap(10)
          .columnsGap(10)
          .width('95%')
          .height(300)
          .scrollBar(BarState.Auto)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      //========add end========

    }
    .onReady((contextNav: NavDestinationContext) => {
      this.pathInfos = contextNav.pathStack;
    })
    .title('专注时钟', {backgroundColor: this.normalBGColor})
    .onShown(async () => {
      //========add start========
      // 页面显示时加载专注记录
      await this.loadFocusRecords();
      //========add end========
    })
  }
}