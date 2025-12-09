export class UserInform {
  id: number;
  user_id: number;
  phone: string;
  email: string;
  gender: string;
  created_at: string;
  updated_at: string;

  constructor(user_id: number, phone: string, email: string, gender: string, id: number, created_at: string, updated_at: string) {
    this.id = id;
    this.user_id = user_id;
    this.phone = phone;
    this.email = email;
    this.gender = gender;
    this.created_at = created_at;
    this.updated_at = updated_at;
  }
}