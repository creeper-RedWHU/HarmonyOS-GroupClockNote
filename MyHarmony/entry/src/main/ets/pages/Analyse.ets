
@Component
export struct Analyse{
  pathInfos:NavPathStack=new NavPathStack();
  name:string='';
  build() {
    NavDestination(){
      Text('hello from Analyse')
    }.onReady((contextNav:NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
    })
  }
}