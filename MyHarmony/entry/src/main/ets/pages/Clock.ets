
@Component
export struct Clock{
  pathInfos:NavPathStack=new NavPathStack();
  name:string='';
  build() {
    NavDestination(){
      Text('hello from Clock')
    }.onReady((contextNav:NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
    })
  }
}