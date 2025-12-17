// 专注记录实体类
export class FocusRecord {
  public id: number;
  public user_id: number;
  public begin_time: string;
  public end_time: string;
  public duration: number;
  public completed: number;
  public created_at: string;
  public updated_at: string;

  constructor(
    user_id: number,
    begin_time: string,
    end_time: string,
    duration: number,
    completed: number,
    id: number = -1,
    created_at: string = '',
    updated_at: string = ''
  ) {
    this.user_id = user_id;
    this.begin_time = begin_time;
    this.end_time = end_time;
    this.duration = duration;
    this.completed = completed;
    this.id = id;
    this.created_at = created_at;
    this.updated_at = updated_at;
  }

  // 格式化时长为可读字符串（如 "25分30秒"）
  getDurationString(): string {
    const minutes = Math.floor(this.duration / 60);
    const seconds = this.duration % 60;
    return `${minutes}分${seconds}秒`;
  }

  // 判断是否完成专注
  isCompleted(): boolean {
    return this.completed === 1;
  }
}