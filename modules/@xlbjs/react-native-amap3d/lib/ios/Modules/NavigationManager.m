//
//  RemoteNotificationCenter.m
//  xlb
//
//  Created by 杨礼正 on 2024/7/22.
//

#import "NavigationManager.h"
#import <UIKit/UIKit.h>
#import "NatviConfigModel.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapNaviKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
//#import <AMapTrackKit/AMapTrackKit.h>
@interface NavigationManager () <AMapNaviCompositeManagerDelegate>
@property (nonatomic, strong) AMapNaviCompositeManager *compositeManager;
@end


@implementation NavigationManager
-(dispatch_queue_t)methodQueue{
  //因为是显示页面，所以让原生接口运行在主线程
  return dispatch_get_main_queue();
}

// RN的回调事件名称列表
-(NSArray<NSString *> *)supportedEvents{
  return @[@"navigationManagerError",
           @"onCalculateRouteSuccess",
           @"onCalculateRouteFailure",
           @"didStartNavi",
           @"updateNaviLocation",
           @"didArrivedDestination"
  ];
}

RCT_EXPORT_MODULE();
static NavigationManager * ins = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[NavigationManager alloc] init];
    });
    return ins;
}
// init
- (AMapNaviCompositeManager *)compositeManager {
    if (!_compositeManager) {
        _compositeManager = [[AMapNaviCompositeManager alloc] init];  // 初始化
        _compositeManager.delegate = [NavigationManager sharedInstance];  // 如果需要使用AMapNaviCompositeManagerDelegate的相关回调（如自定义语音、获取实时位置等），需要设置delegate
    }
    return _compositeManager;
}

// 传入起终点、途径点
- (void)routePlanActionWithConfig:(NSString *)config{
    NSData *jsonData = [config dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSArray *configArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
     
    if (configArray != nil) {
        NSLog(@"Array: %@", configArray);
    } else {
        NSLog(@"Error parsing JSON: %@", error);
    }

    NSMutableArray * configModels = [NSMutableArray array];
    for (int i=0; i<configArray.count; i++) {
        NatviConfigModel * model = [[NatviConfigModel alloc] initWithDic:[configArray objectAtIndex:i]];
        [configModels addObject:model];
    }
    
    AMapNaviCompositeUserConfig *userConfig = [[AMapNaviCompositeUserConfig alloc] init];
    for(NatviConfigModel * model in configModels){
        if(model.type == 0){
            [userConfig setRoutePlanPOIType:AMapNaviRoutePlanPOITypeStart location:[AMapNaviPoint locationWithLatitude:model.lat longitude:model.lon] name:model.name POIId:model.POIId];
        }
        else if(model.type == 1){
            [userConfig setRoutePlanPOIType:AMapNaviRoutePlanPOITypeWay location:[AMapNaviPoint locationWithLatitude:model.lat longitude:model.lon] name:model.name POIId:model.POIId];
        }
        else if(model.type == 2){            [userConfig setRoutePlanPOIType:AMapNaviRoutePlanPOITypeEnd location:[AMapNaviPoint locationWithLatitude:model.lat longitude:model.lon] name:model.name POIId:model.POIId];
        }
    }
    

   [self.compositeManager presentRoutePlanViewControllerWithOptions:userConfig];
}

#pragma mark - AMapNaviCompositeManagerDelegate

// 发生错误时,会调用代理的此方法
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager error:(NSError *)error {
    
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
      __weak __typeof(self)weakSelf = self;
     dispatch_async(dispatch_get_main_queue(), ^{
       __strong typeof(weakSelf) strongSelf = weakSelf;
         [strongSelf sendEventWithName:@"navigationManagerError" body:@{
            @"code":@(error.code),
            @"msg":error.localizedDescription,
            @"data":@{}
         }];
     });

}

// 算路成功后的回调函数,路径规划页面的算路、导航页面的重算等成功后均会调用此方法
- (void)compositeManagerOnCalculateRouteSuccess:(AMapNaviCompositeManager *)compositeManager {
    NSLog(@"onCalculateRouteSuccess,%ld",(long)compositeManager.naviRouteID);
    __weak __typeof(self)weakSelf = self;
   dispatch_async(dispatch_get_main_queue(), ^{
     __strong typeof(weakSelf) strongSelf = weakSelf;
       [strongSelf sendEventWithName:@"onCalculateRouteSuccess" body:@{
          @"code":@(0),
          @"msg":@"",
          @"data":@{@"naviRouteID":@(compositeManager.naviRouteID)}
       }];
   });
}

// 算路失败后的回调函数,路径规划页面的算路、导航页面的重算等失败后均会调用此方法
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager onCalculateRouteFailure:(NSError *)error {
    NSLog(@"onCalculateRouteFailure error:{%ld - %@}", (long)error.code, error.localizedDescription);
    __weak __typeof(self)weakSelf = self;
   dispatch_async(dispatch_get_main_queue(), ^{
     __strong typeof(weakSelf) strongSelf = weakSelf;
       [strongSelf sendEventWithName:@"onCalculateRouteFailure" body:@{
          @"code":@(error.code),
          @"msg":error.localizedDescription,
          @"data":@{}
       }];
   });
}

// 开始导航的回调函数
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager didStartNavi:(AMapNaviMode)naviMode {
    NSLog(@"didStartNavi,%ld",(long)naviMode);
    __weak __typeof(self)weakSelf = self;
   dispatch_async(dispatch_get_main_queue(), ^{
     __strong typeof(weakSelf) strongSelf = weakSelf;
       [strongSelf sendEventWithName:@"onCalculateRouteFailure" body:@{
          @"code":@(0),
          @"msg":@"",
          @"data":@{@"naviMode":@(naviMode)}
       }];
   });
}

// 当前位置更新回调
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager updateNaviLocation:(AMapNaviLocation *)naviLocation {
    NSLog(@"updateNaviLocation,%@",naviLocation);
    __weak __typeof(self)weakSelf = self;
   dispatch_async(dispatch_get_main_queue(), ^{
     __strong typeof(weakSelf) strongSelf = weakSelf;
       [strongSelf sendEventWithName:@"onCalculateRouteFailure" body:@{
          @"code":@(0),
          @"msg":@"",
          @"data":@{@"naviLocation":@{}}
       }];
   });
}

// 导航到达目的地后的回调函数
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager didArrivedDestination:(AMapNaviMode)naviMode {
    NSLog(@"didArrivedDestination,%ld",(long)naviMode);
    __weak __typeof(self)weakSelf = self;
   dispatch_async(dispatch_get_main_queue(), ^{
     __strong typeof(weakSelf) strongSelf = weakSelf;
       [strongSelf sendEventWithName:@"onCalculateRouteFailure" body:@{
          @"code":@(0),
          @"msg":@"",
          @"data":@{@"naviMode":@(naviMode)}
       }];
   });
}

RCT_EXPORT_METHOD(patchNavigationManagerWithMethName:(NSString *)name config:(NSString *)config){
      if([name isEqualToString:@"routePlanAction"]){
          [self routePlanActionWithConfig:config];
      }
}


@end
