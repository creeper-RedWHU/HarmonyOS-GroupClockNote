
@Component
export struct HomePage {
  pathInfos: NavPathStack = new NavPathStack();
  name:string = '';

  build() {
    NavDestination(){
      Text('hello from homepage')
    }.onReady((contextNav:NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
    })
  }
}