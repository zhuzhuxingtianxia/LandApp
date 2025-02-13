//
//  DriveNaviView.h
//  Pods
//
//  Created by 杨礼正 on 2024/8/9.
//

#import <AMapNaviKit/AMapNaviKit.h>
#import <React/RCTComponent.h>
NS_ASSUME_NONNULL_BEGIN

@interface DriveNaviView : AMapNaviDriveView

///驾车、货车路径规划策略.
@property (nonatomic, assign) AMapNaviDrivingStrategy driveStrategy;
/**
 * @brief 设置导航界面地图的日夜模式. since 7.1.0
 * @param type 参考 AMapNaviViewMapModeType . 默认为 AMapNaviViewMapModeTypeDayNightAuto（自动切换模式）
 */
@property (nonatomic, assign) AMapNaviViewMapModeType mapViewModeType;
/**
 * @brief 设置导航语音播报模式. since 7.1.0
 * @param type 参考 AMapNaviCompositeBroadcastType . 默认为 AMapNaviCompositeBroadcastDetailed（详细播报模式）
 */
@property (nonatomic, assign) AMapNaviCompositeBroadcastType broadcastType;
/**
 * @brief 设置导航界面跟随模式. since 7.1.0
 * @param mode 参考 AMapNaviViewTrackingMode . 默认为 AMapNaviViewTrackingModeCarNorth（车头朝上）
 */
@property (nonatomic, assign) AMapNaviViewTrackingMode trackingMode;
/**
 * @brief 设置比例尺智能缩放. since 7.1.0
 * @param autoZoomMapLevel 锁车模式下是否为了预见下一导航动作自动缩放地图. 默认为YES
 */
@property (nonatomic) BOOL autoZoomMapLevel;

@property (nonatomic, copy) RCTDirectEventBlock onMoreButtonClicked;
@property (nonatomic, copy) RCTDirectEventBlock onCloseButtonClicked;


@property (nonatomic, copy) RCTDirectEventBlock onDidEndEmulatorNavi;


@end

NS_ASSUME_NONNULL_END
