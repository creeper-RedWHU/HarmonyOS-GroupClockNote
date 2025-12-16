import { Work } from "./Work";

export class DayWorks{
  day:Date;
  arrays:Array<Work>;
  constructor(
    day:Date,
    works:Array<Work>
  ) {
    this.day=day;
    this.arrays=works;
  }


}