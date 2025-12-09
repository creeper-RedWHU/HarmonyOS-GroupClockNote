// —— 文件名建议如: CustomInputDialog.ets ——
@CustomDialog
export struct CustomInputDialog {
  @Link inputValue: string;                      // 与外部双向绑定的输入内容
  @Link visible: boolean;                        // 控制弹窗显示状态
  fieldLabel: string = '内容';                   // 输入框 Label
  controller?: CustomDialogController;
  onSubmit: (val: string) => void = (val) => {}; // 提交回调

  build() {
    Column() {
      Text(`请输入${this.fieldLabel}:`)
        .fontSize(16)
        .margin({ bottom: 10 })
      TextInput({ placeholder: `在此输入${this.fieldLabel}`, text: this.inputValue })
        .width('90%')
        .onChange(val => this.inputValue = val)
        .margin({ bottom: 18 })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            this.inputValue = "";
            this.controller?.close();
            this.visible = false;
          })
        Button('确定')
          .onClick(() => {
            // 可做输入有效性校验
            if (this.inputValue.trim().length === 0) return;
            this.controller?.close();
            this.visible = false;
            this.onSubmit(this.inputValue.trim()); // 触发外部提交回调
          }).backgroundColor(0x317aff).fontColor(Color.White)
      }
    }
    .padding(18)
    .width('80%')
    .borderRadius(10)
    .backgroundColor(Color.White)
  }
}

@Entry
@Component
export struct CustomDialogUser {
  columnName:string='';
  result:string='';
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: ()=> { this.onCancel() },
      // confirm: ()=> { this.onAccept('') },
      columnName:this.columnName,
      confirm:this.onAccept.bind(this)
    }),
  })
  onCancel() {
    console.info('Callback when the first button is clicked');
  }

  onAccept(x:string) {
    console.info('Callback when the second button is clicked'+x);
    this.result=x;
  }
  build() {
    Column() {
      Button('click me')
        .onClick(() => {
          this.dialogController.open();
        })
    }.width('100%').margin({ top: 5 })
  }
}

@CustomDialog
export struct CustomDialogExample {
  cancel: () => void = () => {
  }
  confirm: (x:string) => void = (x:string) => {
  }
  controller: CustomDialogController;
  columnName:string='';
  @State updateString:string='';


  build() {
    Column() {
      Text('修改'+this.columnName).fontSize(20).margin({ top: 10, bottom: 10 })
      TextInput({placeholder:'修改后的新内容'})
        .onChange((value:string)=>{
          this.updateString=value;
        })

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

              this.confirm(this.updateString);
            }
          }).backgroundColor(0xffffff).fontColor(Color.Blue)
      }.margin({ bottom: 10 })
    }
  }
}


// @Entry
// @Component
// struct NavigationDemo {
//   @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
//   private listArray: Array<string> = ['WLAN', 'Bluetooth', 'Personal Hotpot', 'Connect & Share'];
//
//   build() {
//     Column() {
//       Navigation(this.pathInfos) {
//         TextInput({ placeholder: '输入关键字搜索' })
//           .width('90%')
//           .height(40)
//           .margin({ bottom: 10 })
//
//         // 通过List定义导航的一级界面
//         List({ space: 12, initialIndex: 0 }) {
//           ForEach(this.listArray, (item: string) => {
//             ListItem() {
//               Row() {
//                 Row() {
//                   Text(`${item.slice(0, 1)}`)
//                     .fontColor(Color.White)
//                     .fontSize(14)
//                     .fontWeight(FontWeight.Bold)
//                 }
//                 .width(30)
//                 .height(30)
//                 .backgroundColor('#a8a8a8')
//                 .margin({ right: 20 })
//                 .borderRadius(20)
//                 .justifyContent(FlexAlign.Center)
//
//                 Column() {
//                   Text(item)
//                     .fontSize(16)
//                     .margin({ bottom: 5 })
//                 }
//                 .alignItems(HorizontalAlign.Start)
//
//                 Blank()
//
//                 Row()
//                   .width(12)
//                   .height(12)
//                   .margin({ right: 15 })
//                   .border({
//                     width: { top: 2, right: 2 },
//                     color: 0xcccccc
//                   })
//                   .rotate({ angle: 45 })
//               }
//               .borderRadius(15)
//               .shadow({ radius: 100, color: '#ededed' })
//               .width('90%')
//               .alignItems(VerticalAlign.Center)
//               .padding({ left: 15, top: 15, bottom: 15 })
//               .backgroundColor(Color.White)
//             }
//             .width('100%')
//             .onClick(() => {
//               this.pathInfos.pushPathByName(`${item}`, '详情页面参数')//将name指定的NaviDestination页面信息入栈,传递的参数为param
//             })
//           }, (item: string): string => item)
//         }
//         .listDirection(Axis.Vertical)
//         .edgeEffect(EdgeEffect.Spring)
//         .sticky(StickyStyle.Header)
//         .chainAnimation(false)
//         .width('100%')
//       }
//       .width('100%')
//       .mode(NavigationMode.Auto)
//       .title('设置') // 设置标题文字
//
//       Button('hello');
//     }
//     .size({ width: '100%', height: '100%' })
//     .backgroundColor(0xf4f4f5)
//   }
// }