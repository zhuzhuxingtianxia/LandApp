//
//  DriveNaviView.m
//  Pods
//
//  Created by 杨礼正 on 2024/8/9.
//

#import "DriveNaviView.h"
#import "SpeechSynthesizer.h"
@implementation DriveNaviView
//RCT_EXPORT_VIEW_PROPERTY(driveStrategy, NSUInteger)
//RCT_EXPORT_VIEW_PROPERTY(mapViewModeType, NSUInteger)
//RCT_EXPORT_VIEW_PROPERTY(broadcastType, NSUInteger)
//RCT_EXPORT_VIEW_PROPERTY(trackingMode, NSUInteger)
//RCT_EXPORT_VIEW_PROPERTY(autoZoomMapLevel, BOOL)
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setDriveStrategy:(AMapNaviDrivingStrategy)driveStrategy{
    
//    NSLog(@"llllll");
//    if (self.onMoreButtonClicked) {
//        self.onMoreButtonClicked(@{@"msg":@"打开设置"});
//    }
//    [super setDriveStrategy:driveStrategy];
}
-(void)setMapViewModeType:(AMapNaviViewMapModeType)mapViewModeType{
    [super setMapViewModeType:mapViewModeType];
}
-(void)setBroadcastType:(AMapNaviCompositeBroadcastType)broadcastType{
    
    if(broadcastType == AMapNaviCompositeBroadcastMute )
    {
        [SpeechSynthesizer sharedSpeechSynthesizer].mute = YES;
    }else{
        [SpeechSynthesizer sharedSpeechSynthesizer].mute  = NO;
    }
   
    [[AMapNaviDriveManager sharedInstance]setBroadcastMode:broadcastType];
}
-(void)setTrackingMode:(AMapNaviViewTrackingMode)trackingMode{
    
   
    [super setTrackingMode:trackingMode];
}
-(void)setAutoZoomMapLevel:(BOOL)autoZoomMapLevel{
    [super setAutoZoomMapLevel:autoZoomMapLevel];
}


@end
