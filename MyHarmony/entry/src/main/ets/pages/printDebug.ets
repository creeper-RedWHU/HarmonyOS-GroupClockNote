import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import relationalStore from '@ohos.data.relationalStore';
const DOMAIN = 0x0000;
export class printDebug{
  static printDebug(value:string){
    hilog.info(DOMAIN, 'testTag', '%{public}s', value);

  }
}