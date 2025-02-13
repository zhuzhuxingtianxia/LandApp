//
//  RemoteNotificationCenter.m
//  xlb
//
//  Created by 杨礼正 on 2024/7/22.
//

#import "TrackManager.h"
#import <UIKit/UIKit.h>
#import <AMapTrackKit/AMapTrackKit.h>

@interface TrackModuleManager ()<AMapTrackManagerDelegate>
@property (nonatomic, strong) AMapTrackManager *trackManager;
@property (nonatomic, copy) NSString *serviceID;
@property (nonatomic, copy) NSString *terminalName;
@property (nonatomic, copy) NSString *terminalID;
@property (nonatomic, copy) NSString *trackID;
@property (nonatomic,assign) BOOL creatTrack;

@property (nonatomic, weak) RCTPromiseResolveBlock resolve;
@property (nonatomic, weak) RCTPromiseRejectBlock reject;

@property (nonatomic, weak) RCTPromiseResolveBlock startGatherResolve;
@property (nonatomic, weak) RCTPromiseRejectBlock startGatherReject;


@end


@implementation TrackModuleManager
-(dispatch_queue_t)methodQueue{
    //因为是显示页面，所以让原生接口运行在主线程
    return dispatch_get_main_queue();
    
}

// RN的回调事件名称列表
-(NSArray<NSString *> *)supportedEvents{
    return @[@"onStartGatherAndPackSuccess",
             @"onStartGatherAndPackFailure"
    ];
}

RCT_EXPORT_MODULE();

-(void)creatTrackManager:(NSString *)serviceID terminalID:(NSString *)terminalID{
    
    self.serviceID = serviceID;
    self.terminalID = terminalID;
   
    
    

    AMapTrackManagerOptions *option = [[AMapTrackManagerOptions alloc] init];
    option.serviceID = serviceID; //Service ID 需要根据需要进行修改
    //初始化AMapTrackManager
    self.trackManager = [[AMapTrackManager alloc] initWithOptions:option];
    self.trackManager.delegate = self;
    
  
    [self.trackManager setAllowsBackgroundLocationUpdates:YES];
    [self.trackManager setPausesLocationUpdatesAutomatically:NO];
    
    [self.trackManager changeGatherAndPackTimeInterval:2 packTimeInterval:20];
    [self.trackManager setLocalCacheMaxSize:50];
    
    [self startService];

    
    
  
}

//开始服务
-(void)startService{
    //开始服务
    AMapTrackManagerServiceOption *serviceOption = [[AMapTrackManagerServiceOption alloc] init];
    serviceOption.terminalID = self.terminalID;//Terminal ID 需要根据需要进行修改
    [self.trackManager startServiceWithOptions:serviceOption];
    
    
}
/**
 * @brief 开始采集和上传，结果会通过onStartGatherAndPack:返回
 */
- (void)startGatherAndPackWithTrackID:(NSString *)trackID{
    //开始服务成功，继续开启收集上报
    if(!self.trackManager){
        //开始采集失败
  
           [self sendEventWithName:@"onStartGatherAndPackFailure" body:@{
              @"code":@(-1),
              @"msg":@"上报服务未开启,开始采集失败",
              @"data":@{}
           }];
      
        self.startGatherReject(@"-1",@"上报服务未开启,开始采集失败",nil);
  
    }
        self.trackID = trackID;
        self.trackManager.trackID = trackID;
        [self.trackManager startGatherAndPack];
    
}

/**
 * @brief 停止采集和上传，结果会通过onStopGatherAndPack:返回
 */
- (void)stopGaterAndPackN{
    //开始服务成功，继续开启收集上传
    [self.trackManager stopGaterAndPack];
}

#pragma mark - AMapTrackManagerDelegate



////错误回调
//- (void)didFailWithError:(NSError *)error associatedRequest:(id)request {
//    if ([request isKindOfClass:[AMapTrackQueryTerminalRequest class]]) {
//        //查询参数错误
//        self.reject(@"-1",@"查询参数错误",nil);
//    }
//    
//    if ([request isKindOfClass:[AMapTrackAddTerminalRequest class]]) {
//        //创建terminal失败
//        self.reject(@"-2",@"创建terminal失败",nil);
//    }
//    if ([request isKindOfClass:[AMapTrackAddTrackRequest class]]) {
//        //创建轨迹失败
//        __weak __typeof(self)weakSelf = self;
//       dispatch_async(dispatch_get_main_queue(), ^{
//         __strong typeof(weakSelf) strongSelf = weakSelf;
//           [strongSelf sendEventWithName:@"onStartGatherAndPackFailure" body:@{
//              @"code":@(-1),
//              @"msg":@"创建轨迹失败",
//              @"data":@{}
//           }];
//           strongSelf.startGatherReject(@"-1",@"创建轨迹失败",nil);
//       });
//    }
//}
//service 开始Service回调
- (void)onStartService:(AMapTrackErrorCode)errorCode {
    if (errorCode == AMapTrackErrorOK) {
        self.resolve(@'0');
        
    } else {
        //开始服务失败
        self.reject(@"-1",@"开始服务失败",nil);
    }
}
-(void)onStopGatherAndPack:(AMapTrackErrorCode)errorCode{
    NSLog(@"停止采集");
}
//开始采集和上传回调
- (void)onStartGatherAndPack:(AMapTrackErrorCode)errorCode {
    if (errorCode == AMapTrackErrorOK) {
        //开始采集成功
  
  
           [self sendEventWithName:@"onStartGatherAndPackSuccess" body:@{
              @"code":@(0),
              @"msg":@"开始采集成功",
              @"data":@{@"trackID":self.trackID?self.trackID:@""}
           }];
        self.startGatherResolve(self.trackID?self.trackID:@"");
     
    } else {
        //开始采集失败
     
 
           [self sendEventWithName:@"onStartGatherAndPackFailure" body:@{
              @"code":@(-1),
              @"msg":@"开始采集失败",
              @"data":@{}
           }];
        self.startGatherReject(@"-1",@"开始采集失败",nil);
  
    }
}



RCT_EXPORT_METHOD(initTrackManager:(NSString *)serviceID terminalID:(NSString *)terminalID   resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    if(!serviceID || !terminalID){
        reject(@"-1",@"参数缺失",nil);
    }
    if(resolve){
        self.resolve=resolve;
    }
    if(reject){
        self.reject=reject;
    }
    [self creatTrackManager:serviceID terminalID:terminalID];
}
RCT_EXPORT_METHOD(startGatherAndPack:(NSString *)trackID resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    if(!trackID){
        reject(@"-1",@"参数缺失",nil);
    }
    if(resolve){
        self.startGatherResolve=resolve;
    }
    if(reject){
        self.startGatherReject=reject;
    }
    [self startGatherAndPackWithTrackID:trackID];
    
}
RCT_EXPORT_METHOD(stopGaterAndPack){
    [self stopGaterAndPackN];
}

@end
