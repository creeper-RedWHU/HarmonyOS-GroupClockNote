@Component
export struct CalendarPage{
  pathInfos:NavPathStack=new NavPathStack();
  name:string='';
  build() {
    NavDestination(){
      Text('hello from CalendarPage')
    }.onReady((contextNav:NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
    })
  }
}