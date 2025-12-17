//========add start========
import { FocusRecordDao } from './database';
import { FocusRecord } from './Entities/RecordOFocus';
//========add end========

@Component
export struct Analyse{
  pathInfos:   NavPathStack=new NavPathStack();
  name: string='';
  userID: number=0;

  //========add start========
  normalBGColor: string='#018f8f';
  todayBGColor: string='#32bdc0';

  @State totalDuration: number = 0;          // 总专注时长（秒）
  @State todayFocusCount: number = 0;        // 今日专注次数
  @State totalFocusCount: number = 0;        // 总专注次数
  @State completedCount: number = 0;         // 完成次数
  @State uncompletedCount:  number = 0;       // 未完成次数
  @State completionRate: number = 0;         // 完成率
  @State averageDuration: number = 0;        // 平均专注时长（秒）
  @State longestDuration: number = 0;        // 最长专注时长（秒）
  @State recentRecords: FocusRecord[] = [];  // 最近的专注记录

  // 格式化时长为可读字符串
  formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) {
      return `${hours}小时${minutes}分${secs}秒`;
    } else if (minutes > 0) {
      return `${minutes}分${secs}秒`;
    } else {
      return `${secs}秒`;
    }
  }

  // 格式化时长为简短字符串（用于大数字显示）
  formatDurationShort(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);

    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    } else if (minutes > 0) {
      return `${minutes}m`;
    } else {
      return `${seconds}s`;
    }
  }

  // 加载统计数据
  // 加载统计数据
  async loadStatistics() {
    try {
      console.log(`开始加载用户${this.userID}的统计数据`);

      // 1. 获取所有记录进行统计（先获取全部数据）
      const allRecords = await FocusRecordDao.getFocusRecordByUserId(this.userID);
      console.log(`获取到${allRecords.length}条记录`);
      console.log(`allRecords length:${allRecords.length}`);

      //========修改 start========
      // 先重置所有状态为0，确保清空旧数据
      this.totalFocusCount = 0;
      this.completedCount = 0;
      this.uncompletedCount = 0;
      this.completionRate = 0;
      this.totalDuration = 0;
      this.averageDuration = 0;
      this.longestDuration = 0;
      this.todayFocusCount = 0;
      this.recentRecords = [];

      // 如果没有记录，直接返回
      if (allRecords. length === 0) {
        console.log('没有任何记录');
        return;
      }

      // 2. 统计总次数（触发状态更新）
      this. totalFocusCount = allRecords.length;
      console. log(`总次数更新为:  ${this.totalFocusCount}`);

      // 3. 分离完成和未完成记录
      const completedRecords = allRecords.filter(r => r.completed === 1);
      const uncompletedRecords = allRecords.filter(r => r.completed === 0);

      // 立即更新状态
      this.completedCount = completedRecords.length;
      this. uncompletedCount = uncompletedRecords.length;

      console.log(`完成: ${this.completedCount}, 未完成: ${this. uncompletedCount}`);

      // 4. 计算完成率（触发状态更新）
      if (this.totalFocusCount > 0) {
        this.completionRate = Math.round((this.completedCount / this.totalFocusCount) * 100);
      }
      console.log(`完成率:  ${this.completionRate}%`);

      // 5. 计算总专注时长（只统计完成的）
      if (completedRecords.length > 0) {
        let sum = 0;
        for (let record of completedRecords) {
          sum += record.duration;
        }
        this. totalDuration = sum;
      }
      console.log(`总时长更新为: ${this.totalDuration}秒`);

      // 6. 计算平均专注时长（只统计完成的）
      if (completedRecords.length > 0) {
        this.averageDuration = Math.floor(this.totalDuration / completedRecords.length);
      }
      console.log(`平均时长更新为: ${this.averageDuration}秒`);

      // 7. 找出最长专注时长（只统计完成的）
      if (completedRecords.length > 0) {
        let maxDuration = 0;
        for (let record of completedRecords) {
          if (record.duration > maxDuration) {
            maxDuration = record.duration;
          }
        }
        this.longestDuration = maxDuration;
      }
      console.log(`最长记录更新为: ${this. longestDuration}秒`);

      // 8. 获取今日专注次数（只统计完成的）
      this.todayFocusCount = await FocusRecordDao.getTodayFocusCount(this.userID);
      console.log(`今日专注更新为: ${this.todayFocusCount}次`);

      // 9. 获取最近5条记录（创建新数组触发更新）
      this.recentRecords = allRecords.slice(0, 5);
      console.log(`最近记录数:  ${this.recentRecords. length}`);

      // 强制打印所有状态变量，确认更新
      console.log('=== 最终状态 ===');
      console.log(`totalFocusCount: ${this. totalFocusCount}`);
      console.log(`completedCount: ${this.completedCount}`);
      console.log(`uncompletedCount: ${this. uncompletedCount}`);
      console.log(`completionRate: ${this.completionRate}%`);
      console.log(`totalDuration: ${this.totalDuration}秒`);
      console.log(`averageDuration: ${this.averageDuration}秒`);
      console.log(`longestDuration: ${this.longestDuration}秒`);
      console.log(`todayFocusCount: ${this.todayFocusCount}次`);
      console.log('================');

      console.log(`统计数据加载完成`);
      //========修改 end========

    } catch (err) {
      console.error('加载统计数据失败:', err);
      // 出错时重置所有数据为0
      this.totalDuration = 0;
      this.todayFocusCount = 0;
      this.totalFocusCount = 0;
      this.completedCount = 0;
      this.uncompletedCount = 0;
      this.completionRate = 0;
      this.averageDuration = 0;
      this.longestDuration = 0;
      this.recentRecords = [];
    }
  }
  // 格式化时间显示（只显示时分）
  formatTimeOnly(dateStr: string): string {
    if (!dateStr || dateStr.length < 16) return '--:--';
    return dateStr.substring(11, 16);
  }

  // 格式化日期显示
  formatDateOnly(dateStr:  string): string {
    if (! dateStr || dateStr.length < 10) return '--/--';
    return dateStr.substring(5, 10); // MM-DD
  }
  //========add end========

  build() {
    NavDestination(){
      //========add start========
      Scroll() {
        Column({ space: 15 }) {
          // 标题区域
          Text(this.name + '的专注分析')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.normalBGColor)
            .margin({ top: 20, bottom:  10 })

          // 核心统计卡片
          Grid() {
            // 总专注时长
            GridItem() {
              Column() {
                Text('📊')
                  .fontSize(32)
                  .margin({ bottom: 8 })
                Text(this.formatDurationShort(this.totalDuration))
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.normalBGColor)
                Text('总专注时长')
                  . fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 5 })
              }
              . width('100%')
              .padding(20)
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .borderRadius(15)
              .shadow({
                radius: 10,
                color: '#1F000000',
                offsetX: 0,
                offsetY: 3
              })
            }

            // 今日专注次数
            GridItem() {
              Column() {
                Text('🔥')
                  .fontSize(32)
                  .margin({ bottom: 8 })
                Text(`${this.todayFocusCount}`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  . fontColor('#FF6B6B')
                Text('今日专注')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 5 })
              }
              .width('100%')
              .padding(20)
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .borderRadius(15)
              .shadow({
                radius: 10,
                color:  '#1F000000',
                offsetX: 0,
                offsetY: 3
              })
            }

            // 完成率
            GridItem() {
              Column() {
                Text('✅')
                  . fontSize(32)
                  . margin({ bottom: 8 })
                Text(`${this.completionRate}%`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#4CAF50')
                Text('完成率')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 5 })
              }
              .width('100%')
              .padding(20)
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .borderRadius(15)
              .shadow({
                radius: 10,
                color: '#1F000000',
                offsetX:  0,
                offsetY:  3
              })
            }

            // 总专注次数
            GridItem() {
              Column() {
                Text('📈')
                  .fontSize(32)
                  .margin({ bottom: 8 })
                Text(`${this.totalFocusCount}`)
                  .fontSize(24)
                  . fontWeight(FontWeight.Bold)
                  .fontColor('#9C27B0')
                Text('总专注次数')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 5 })
              }
              .width('100%')
              .padding(20)
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .borderRadius(15)
              .shadow({
                radius: 10,
                color: '#1F000000',
                offsetX: 0,
                offsetY: 3
              })
            }
          }
          .columnsTemplate('1fr 1fr')
          .rowsTemplate('1fr 1fr')
          .rowsGap(15)
          .columnsGap(15)
          .width('90%')
          .height(320)

          // 详细统计区域
          Column({ space: 10 }) {
            Text('详细统计')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.normalBGColor)
              .alignSelf(ItemAlign.Start)
              .margin({ left: 20, top: 10 })

            // 统计列表
            Column() {
              Row() {
                Text('✓')
                  .width(24)
                  .fontColor('#4CAF50')
                  .margin({ right: 15 })

                Column({ space: 3 }) {
                  Text('完成次数')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.completedCount+'')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                }
                .alignItems(HorizontalAlign.Start)

                Blank()
              }
              .width('100%')
              .padding({ top: 10, bottom: 10 })
              // this.StatisticItem('完成次数', `${}次`, '✓', '#4CAF50')
              Divider().color('#F0F0F0')
              Row() {
                Text('○')
                  .width(24)
                  .fontColor('#FF9800')
                  .margin({ right: 15 })

                Column({ space: 3 }) {
                  Text('未完成次数')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.uncompletedCount+'')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                }
                .alignItems(HorizontalAlign.Start)

                Blank()
              }
              .width('100%')
              .padding({ top: 10, bottom: 10 })

              Divider().color('#F0F0F0')
              Row() {
                Text('⏱')
                  .width(24)
                  .fontColor('#018f8f')
                  .margin({ right: 15 })

                Column({ space: 3 }) {
                  Text('平均时长')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.formatDuration(this.averageDuration)+'')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                }
                .alignItems(HorizontalAlign.Start)

                Blank()
              }
              .width('100%')
              .padding({ top: 10, bottom: 10 })
              Divider().color('#F0F0F0')
              Row() {
                Text('🏆')
                  .width(24)
                  .fontColor('#FFD700')
                  .margin({ right: 15 })

                Column({ space: 3 }) {
                  Text('最长记录')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.formatDuration(this.longestDuration)+'')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                }
                .alignItems(HorizontalAlign.Start)

                Blank()
              }
              .width('100%')
              .padding({ top: 10, bottom: 10 })
            }
            .width('90%')
            .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
            .borderRadius(15)
            .padding(15)
            .shadow({
              radius: 10,
              color: '#1F000000',
              offsetX: 0,
              offsetY: 3
            })
          }
          .width('100%')

          // 最近记录
          Column({ space: 10 }) {
            Text('最近记录')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.normalBGColor)
              .alignSelf(ItemAlign.Start)
              .margin({ left: 20, top: 10 })

            if (this.recentRecords. length === 0) {
              Column() {
                Text('暂无记录')
                  . fontSize(14)
                  .fontColor('#999999')
              }
              .width('90%')
              .height(100)
              .justifyContent(FlexAlign.Center)
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .borderRadius(15)
            } else {
              Column() {
                ForEach(this.recentRecords, (record: FocusRecord, index: number) => {
                  Column() {
                    Row() {
                      Column({ space: 5 }) {
                        Text(`${this.formatDateOnly(record.begin_time)} ${this.formatTimeOnly(record.begin_time)}`)
                          .fontSize(14)
                          . fontColor('#333333')
                        Text(record.getDurationString())
                          .fontSize(12)
                          .fontColor('#666666')
                      }
                      .alignItems(HorizontalAlign.Start)

                      Blank()

                      Text(record.completed === 1 ? '✓' : '○')
                        .fontSize(18)
                        .fontColor(record.completed === 1 ? '#4CAF50' :  '#FF9800')
                        .padding(8)
                        .borderRadius(20)
                        .backgroundColor(record.completed === 1 ? '#E8F5E9' : '#FFF3E0')
                    }
                    .width('100%')
                    .padding(12)

                    if (index < this.recentRecords.length - 1) {
                      Divider().color('#F0F0F0')
                    }
                  }
                })
              }
              .width('90%')
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .borderRadius(15)
              .shadow({
                radius: 10,
                color: '#1F000000',
                offsetX: 0,
                offsetY: 3
              })
            }
          }
          .width('100%')
          .margin({ bottom: 20 })
          Column({ space: 10 }) {
            Text('AI分析')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.normalBGColor)
              .alignSelf(ItemAlign.Start)
              .margin({ left: 20, top: 10 })

            if (this.recentRecords. length === 0) {
              Column() {
                Text('请先专注才有分析噢！')
                  . fontSize(14)
                  .fontColor('#999999')
              }
              .width('90%')
              .height(100)
              .justifyContent(FlexAlign.Center)
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .borderRadius(15)
            } else {
              Column() {

                  Column() {
                    Row() {
                      Column({ space: 5 }) {
                        Text('从今天的专注数据来看，你的专注情况还有很大的提升空间。总时长仅有10秒，今日专注次数为1次，虽然完成率为50%，但这表明你至少开始了一次专注尝试。从详细统计来看，完成和未完成次数各为1次，平均时长和最长记录均为10秒，说明这次专注过程可能比较短暂，未能持续深入。建议可以尝试设定更明确的小目标，逐步延长每次专注的时间，培养更稳定的专注习惯。只要坚持记录和调整，专注力会逐渐改善的，继续加油！')
                      }
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .padding(12)

                  }

              }
              .width('90%')
              .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              .borderRadius(15)
              .shadow({
                radius: 10,
                color: '#1F000000',
                offsetX: 0,
                offsetY: 3
              })
            }
          }
          .width('100%')
          .margin({ bottom: 20 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .scrollBar(BarState.Auto)
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      //========add end========
    }
    .onReady((contextNav:  NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
    })
    //========add start========
    .onShown(() => {
      // 页面显示时加载统计数据
      console.log('Analyse页面显示，开始加载数据');
      this.loadStatistics();
    })
    .title('专注分析', { backgroundColor: this.normalBGColor })
    //========add end========
  }

  //========add start========
  // 统计项组件
  @Builder
  StatisticItem(label: string, value: string, icon: string, iconColor: ResourceColor) {
    Row() {
      Text(icon)
        .fontSize(24)
        .fontColor(iconColor)
        .margin({ right: 15 })

      Column({ space: 3 }) {
        Text(label)
          .fontSize(14)
          .fontColor('#666666')
        Text(value)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }
  //========add end========
}