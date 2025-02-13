//
//  DriveNaviViewManager.m
//  react-native-amap3d
//
//  Created by 杨礼正 on 2024/8/9.
//

#import "DriveNaviViewManager.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import "DriveNaviView.h"
#import "MoreMenuView.h"
#import "SpeechSynthesizer.h"
@interface DriveNaviViewManager()<AMapNaviDriveManagerDelegate,AMapNaviDriveViewDelegate, MoreMenuViewDelegate>

@property (nonatomic, strong) DriveNaviView *driveView;
@property (nonatomic, strong) NSArray <AMapNaviPOIInfo *> *wayPoints;
@property (nonatomic, strong) NSArray <AMapNaviCompositeCustomAnnotation *> *wayAnnotation;
@end


@implementation DriveNaviViewManager
RCT_EXPORT_MODULE(DriveNaviView)



RCT_EXPORT_VIEW_PROPERTY(driveStrategy, NSUInteger)
RCT_EXPORT_VIEW_PROPERTY(mapViewModeType, NSUInteger)
RCT_EXPORT_VIEW_PROPERTY(broadcastType, NSUInteger)
RCT_EXPORT_VIEW_PROPERTY(trackingMode, NSUInteger)
RCT_EXPORT_VIEW_PROPERTY(autoZoomMapLevel, BOOL)

RCT_EXPORT_VIEW_PROPERTY(onMoreButtonClicked, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCloseButtonClicked, RCTBubblingEventBlock)


RCT_EXPORT_VIEW_PROPERTY(onDidEndEmulatorNavi, RCTBubblingEventBlock)

- (UIView *)view
{
    _driveView = nil;
    
  return self.driveView;
}

-(DriveNaviView *)driveView{
    if(_driveView == nil){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initWayAnnotation:) name:@"CHANGEWAYPOINTS" object:nil];
        _driveView= [[DriveNaviView alloc] init];
        _driveView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_driveView setDelegate:self];
        [_driveView setShowGreyAfterPass:YES];
        [_driveView setAutoZoomMapLevel:YES];
        _driveView.showMoreButton = YES;
        _driveView.backgroundColor =[UIColor colorWithRed:255 green:254 blue:155 alpha:1];
        [_driveView setTrackingMode:AMapNaviViewTrackingModeCarNorth];
        [_driveView setMapViewModeType:AMapNaviViewMapModeTypeDayNightAuto];
//        [_driveView setStartPointImage:[UIImage imageNamed:@"startIcon"]];
//        [_driveView setEndPointImage:[UIImage imageNamed:@"endIcon"]];
        [_driveView setWayPointImage:[UIImage imageNamed:@"wayIconDef1"]];
        [[AMapNaviDriveManager sharedInstance] addDataRepresentative:_driveView];
//        [[AMapNaviDriveManager sharedInstance] setIsUseInternalTTS:YES];
        [[AMapNaviDriveManager sharedInstance] setDelegate:self];

    }
  
    return _driveView;
}
- (void)initWayAnnotation:(NSNotification *)data {
    NSArray * array =  data.object;
    self.wayPoints = [NSArray arrayWithArray:array];
    if (_wayAnnotation != nil) {
        for(int i=0;i<self.wayAnnotation.count;i++)
        {
            [self.driveView removeCustomAnnotation:self.wayAnnotation[i]];
        }
       
    }
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 这里是你想要延迟执行的代码
        NSMutableArray * array = [NSMutableArray array];
        for(int i=0;i<weakSelf.wayPoints.count;i++)
        {
            AMapNaviPOIInfo *point = weakSelf.wayPoints[i];
            
            UIImageView * imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
            
            imageView.image= [UIImage imageNamed:@"wayIconDef"];
            
            AMapNaviCompositeCustomAnnotation *  annotation = [[AMapNaviCompositeCustomAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(point.locPoint.latitude, point.locPoint.longitude) view:imageView];
            
        
//            annotation.title = [NSString stringWithFormat:@"%d",i+1];
       
            [array addObject:annotation];
            [weakSelf.driveView addCustomAnnotation:annotation];
   
        }
        weakSelf.wayAnnotation = [NSArray arrayWithArray:array];
    });
    
    
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.driveView.mapViewModeType == AMapNaviViewMapModeTypeNight ?  UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}
-(dispatch_queue_t)methodQueue{
  //因为是显示页面，所以让原生接口运行在主线程
  return dispatch_get_main_queue();
}
+ (BOOL)requiresMainQueueSetup
{
  return YES;  // 请仅在您的模块初始化需要调用 UIKit 时才这样做！
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - DriveView Delegate

- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView
{
    if (self.driveView && self.driveView.onCloseButtonClicked)
    {
        self.driveView.onCloseButtonClicked(@{@"msg":@"关闭导航"});
    }
   
}

- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView
{
    
    if (self.driveView && self.driveView.onMoreButtonClicked)
    {
       
       self.driveView.onMoreButtonClicked(@{@"msg":@"打开设置"});
       
    }

}

- (void)driveViewTrunIndicatorViewTapped:(AMapNaviDriveView *)driveView
{
    if (self.driveView.showMode == AMapNaviDriveViewShowModeCarPositionLocked)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeNormal];
    }
    else if (self.driveView.showMode == AMapNaviDriveViewShowModeNormal)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeOverview];
    }
    else if (self.driveView.showMode == AMapNaviDriveViewShowModeOverview)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeCarPositionLocked];
    }
}

- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode
{
    NSLog(@"didChangeShowMode:%ld", (long)showMode);
}

- (void)driveView:(AMapNaviDriveView *)driveView didChangeDayNightType:(BOOL)showStandardNightType {
    NSLog(@"didChangeDayNightType:%ld", (long)showStandardNightType);
 /*   [self setNeedsStatusBarAppearanceUpdate]; */ //更新状态栏颜色
}
- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{
    if (self.driveView.onDidEndEmulatorNavi) {
        self.driveView.onDidEndEmulatorNavi(@{@"msg":@"到达目的地"});
    }
}
- (BOOL)driveManagerIsNaviSoundPlaying:(AMapNaviDriveManager *)driveManager
{
    return [[SpeechSynthesizer sharedSpeechSynthesizer] isSpeaking];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    if (![SpeechSynthesizer sharedSpeechSynthesizer].mute) {
        [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
    }
   
}

@end
