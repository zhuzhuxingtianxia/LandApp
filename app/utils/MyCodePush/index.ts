/*
// Use a different deployment key for this
// specific call, instead of the one configured
// in the Info.plist file
codePush.sync({ deploymentKey: "KEY" });

// Download the update silently, but install it on
// the next resume, as long as at least 5 minutes
// has passed since the app was put into the background.
codePush.sync({ installMode: codePush.InstallMode.ON_NEXT_RESUME, minimumBackgroundDuration: 60 * 5 });

// Download the update silently, and install optional updates
// on the next restart, but install mandatory updates on the next resume.
codePush.sync({ mandatoryInstallMode: codePush.InstallMode.ON_NEXT_RESUME });

// Changing the title displayed in the
// confirmation dialog of an "active" update
codePush.sync({ updateDialog: { title: "An update is available!" } });

// Displaying an update prompt which includes the
// description associated with the CodePush release
codePush.sync({
   updateDialog: {
    appendReleaseDescription: true,
    descriptionPrefix: "\n\nChange log:\n"
   },
   installMode: codePush.InstallMode.IMMEDIATE
});

// Prompt the user when an update is available
// and then display a "downloading" modal
codePush.sync({ updateDialog: true },
  (status) => {
      switch (status) {
          case codePush.SyncStatus.DOWNLOADING_PACKAGE:
              // Show "downloading" modal
              break;
          case codePush.SyncStatus.INSTALLING_UPDATE:
              // Hide "downloading" modal
              break;
      }
  },
  ({ receivedBytes, totalBytes, }) => {
     // Update download modal progress
});

*/

import { Platform, DeviceEventEmitter } from 'react-native';
import CodePush, { DownloadProgress, RemotePackage } from 'react-native-code-push';

const deploymentKeyMap = Platform.OS === 'ios'
    ? {
        test: 'YOUR_DEPLOYMENT_KEY',
        sit: 'YOUR_DEPLOYMENT_KEY',
        uat: 'YOUR_DEPLOYMENT_KEY',
        prd: 'YOUR_DEPLOYMENT_KEY',
    }
    : {
        test: 'YOUR_DEPLOYMENT_KEY',
        sit: 'YOUR_DEPLOYMENT_KEY',
        uat: 'YOUR_DEPLOYMENT_KEY',
        prd: 'YOUR_DEPLOYMENT_KEY',
    }
const getDeploymentKey = () => {
    const key = (global as any).env as keyof typeof deploymentKeyMap ?? 'test';
    const deploymentKey = deploymentKeyMap[key];
    return deploymentKey;
};

const MyCodePush = async () => {
    await CodePush.notifyAppReady();
    const update: RemotePackage | null = await CodePush.checkForUpdate(getDeploymentKey());
    if (update) {
        CodePush.disallowRestart();
        CodePush.sync({
            deploymentKey: getDeploymentKey(),
            mandatoryInstallMode: CodePush.InstallMode.ON_NEXT_RESTART,
            // 可选更新
            // installMode: CodePush.InstallMode.IMMEDIATE,
            updateDialog: {
                appendReleaseDescription: true,
                descriptionPrefix: '\n\nChange log:\n',
                mandatoryContinueButtonLabel: 'Update and Restart',
                mandatoryUpdateMessage: 'A new update is available, please update!',
                title: 'New Update',
            }
        },(status: CodePush.SyncStatus) => {
            // 安装完更新包状态
            if (status === CodePush.SyncStatus.UPDATE_INSTALLED) {
                // update.isMandatory 是否强制更新
                console.log('更新包安装完成');
                setTimeout(() => {
                    // CodePush.allowRestart();
                    // CodePush.restartApp();
                }, 3000);
            }
        },(progress: DownloadProgress) => {
            CodePush.allowRestart();
            // DeviceEventEmitter.emit('codePushUpdate', true);
        })
        
    }
}

export {
   MyCodePush
};