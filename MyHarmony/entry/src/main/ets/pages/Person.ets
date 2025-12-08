
@Component
export struct Person{
  pathInfos:NavPathStack=new NavPathStack();
  name:string='';
  build() {
    NavDestination(){
      Text('hello from Person')
    }.onReady((contextNav:NavDestinationContext)=>{
      this.pathInfos=contextNav.pathStack;
    })
  }
}