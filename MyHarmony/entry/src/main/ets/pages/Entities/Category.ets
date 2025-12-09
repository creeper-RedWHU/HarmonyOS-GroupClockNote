export class Category{
  categoryID:number;
  categoryName:string;
  user_id:string;
  constructor(
  categoryID:number,
  categoryName:string,
  user_id:string,
  ) {
    this.categoryID=categoryID;
    this.categoryName=categoryName;
    this.user_id=user_id;
  }
}