//==========User==========
//id,name,password,created_at,updated_at

export class User{
  id:number;
  name:string;
  password:string;
  created_at:string;
  updated_at:string;
  constructor(name:string,password:string,id:number,created_at:string,updated_at:string) {
    this.id=id;
    this.name=name;
    this.password=password;
    this.created_at=created_at;
    this.updated_at=updated_at;
  }
}