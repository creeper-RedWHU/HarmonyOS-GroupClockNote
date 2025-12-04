import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import {UserDBManager}from '../pages/database'

const DOMAIN = 0x0000;


export default class FirstPageAbility extends UIAbility{
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context=this.context;
    // this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN,'testTag', '%{public}s', 'FistPage Ability onCreate');
  }
  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'FistPage Ability onDestroy');
  }
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'FirstPage Ability onWindowStageCreate');
    windowStage.loadContent('pages/FirstPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the FirstPage content.');
    });

  }
  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'FistPage Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'FistPage Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'FistPage Ability onBackground');
  }
}