export class Work{
  work_id:number;
  user_id:number;
  // title:string;
  description:string;
  category:string;
  dateTime:Date;
  completed:number;//0:false,1:true
  constructor(
  work_id:number,
  user_id:number,
  // title:string,
  description:string,
  category:string,
  dateTime:Date
  ) {
    this.work_id=work_id;
    this.user_id=user_id;
    // this.title=title;
    this.description=description;
    this.category=category;
    this.dateTime=dateTime;
    this.completed=0;
  }
}