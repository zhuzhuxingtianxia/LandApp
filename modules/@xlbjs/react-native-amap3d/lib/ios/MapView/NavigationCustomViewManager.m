//
//  NavigationViewController.m
//  react-native-amap3d
//
//  Created by 杨礼正 on 2024/8/7.
//

#import "NavigationCustomViewManager.h"
#import "NaviPointAnnotation.h"
#import "SelectableOverlay.h"
#import "RouteCollectionViewCell.h"
#import "PreferenceView.h"
#import "MultiDriveRoutePolyline.h"
#import "DriveRouteDataModel.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import "NavigationMapView.h"
#import "CommonUtility.h"
#import "SpeechSynthesizer.h"
#define kRoutePlanInfoViewHeight    130.f
#define kRouteIndicatorViewHeight   64.f
#define kCollectionCellIdentifier   @"kCollectionCellIdentifier"
#define AMapNaviRoutePolylineDefaultWidth  30.f
@interface NavigationCustomViewManager ()<MAMapViewDelegate, AMapNaviDriveManagerDelegate>

@property (nonatomic, strong) NavigationMapView *mapView;
@property (nonatomic, strong) NSArray * properties;


@property (nonatomic, strong) AMapNaviPOIInfo *startPoint;
@property (nonatomic, strong) NaviPointAnnotation *beginAnnotation;

@property (nonatomic, strong) AMapNaviPOIInfo *endPoint;
@property (nonatomic, strong) NaviPointAnnotation *endAnnotation;
@property (nonatomic, strong) NSArray <AMapNaviPOIInfo *> *wayPoints;
@property (nonatomic, assign) NSInteger routeID;

@property (nonatomic, strong) NSArray <NaviPointAnnotation *> *wayAnnotation;


@property (nonatomic, strong) UICollectionView *routeIndicatorView;
@property (nonatomic, strong) NSMutableArray *routeIndicatorInfoArray;
@property (nonatomic, strong) PreferenceView *preferenceView;
//------- 路线数据详情
@property (nonatomic, strong) UIScrollView *maskView;
@property (nonatomic, strong) UILabel *detailDataLabel;
@property (nonatomic, strong) NSArray *routeDataSource;

@property (nonatomic, assign) BOOL isMultipleRoutePlan;
@end

@implementation NavigationCustomViewManager


RCT_EXPORT_MODULE(NavigationCustomView)

RCT_EXPORT_VIEW_PROPERTY(startPoint, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(endPoint, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(points, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(wayPoints, NSArray)
RCT_EXPORT_VIEW_PROPERTY(routeID, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(onCalculateRouteSuccess, RCTBubblingEventBlock)


RCT_EXPORT_METHOD(startGPSNavi){
    //算路成功后开始GPS导航
    [[AMapNaviDriveManager sharedInstance] startGPSNavi];
      __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGEWAYPOINTS" object:weakSelf.wayPoints];
    });
}
RCT_EXPORT_METHOD(stopNavi){
    //停止语音
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    //停止GPS导航
    [[AMapNaviDriveManager sharedInstance] stopNavi];
   
}

RCT_EXPORT_METHOD(reFreshNaviRout:(NSInteger)type){
    //重新规划
    if (self.startPoint != nil && self.endPoint!= nil) {
        self.isMultipleRoutePlan = YES;
        [[AMapNaviDriveManager sharedInstance] setMultipleRouteNaviMode:YES];
        NSLog(@"999888999=>%@",self.wayPoints);
        [[AMapNaviDriveManager sharedInstance] calculateDriveRouteWithStartPOIInfo:self.startPoint endPOIInfo:self.endPoint wayPOIInfos:self.wayPoints drivingStrategy:type];
    }
}

RCT_EXPORT_METHOD(reFreshUserLocation){
    //定位用户位置
    self.mapView.showsUserLocation=YES;
    self.mapView.userTrackingMode= MAUserTrackingModeFollowWithHeading;
}
/**
 * @brief 判断经纬度点是否在圆内
 * @param point  经纬度
 * @param center 圆的中心经纬度
 * @param radius 圆的半径，单位米
 * @return 判断结果
 */

RCT_EXPORT_METHOD(MACircleContainsCoordinate:(NSDictionary *)point center:(NSDictionary *)center radius:(double)radius resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    CLLocationCoordinate2D *points2D = (CLLocationCoordinate2D *)malloc(1 * sizeof(CLLocationCoordinate2D));
 
    points2D[0].latitude = [point[@"latitude"] doubleValue];
        
    points2D[0].longitude = [point[@"longitude"] doubleValue];
    
    CLLocationCoordinate2D *centers2D = (CLLocationCoordinate2D *)malloc(1 * sizeof(CLLocationCoordinate2D));
 
    centers2D[0].latitude = [center[@"latitude"] doubleValue];
        
    centers2D[0].longitude = [center[@"longitude"] doubleValue];
    
    BOOL isIn =  MACircleContainsCoordinate(points2D[0],centers2D[0],radius);
    
    if (isIn == YES) {
        resolve(@(1));
    }else{
        resolve(@(0));
    }


}
//将GPS转成高德坐标
RCT_EXPORT_METHOD(AMapCoordinateConvert:(NSDictionary *)point  type:(NSUInteger)type resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    if(!point)
    {
        reject(@"-1",@"参数缺失",nil);
    }
    CLLocationCoordinate2D amapcoord = AMapCoordinateConvert(CLLocationCoordinate2DMake([point[@"latitude"] doubleValue] ,[point[@"longitude"] doubleValue] ), type);
    if (amapcoord.latitude && amapcoord.longitude) {
        resolve(@{
            @"latitude":@(amapcoord.latitude),
            @"longitude":@(amapcoord.longitude)
        });
    }else{
        reject(@"-1",@"转换失败",nil);
    }

}





#pragma mark - Life Cycle
- (UIView *)view
{
    _mapView = nil;
  return self.mapView;
}
-(NavigationMapView *)mapView{
    if (_mapView == nil) {
        _mapView = [[NavigationMapView alloc] init];
            [_mapView setDelegate:self];
            [[AMapNaviDriveManager sharedInstance] setDelegate:self];
            [_mapView setMapType:MAMapTypeNavi];
        _mapView.showTraffic = YES;
        _mapView.showsUserLocation = YES;
        _mapView.showsCompass = NO;
        _mapView.backgroundColor =[UIColor colorWithRed:255 green:254 blue:155 alpha:1];
        [_mapView setCenterCoordinate:_mapView.userLocation.coordinate];
             __weak __typeof(self)weakSelf = self;
        _mapView.navigationMapBlock = ^(NSInteger type, NSArray * _Nonnull points) {
                if (type == AMapNaviRoutePlanPOITypeStart) {
                    weakSelf.startPoint = points[0];
                    [weakSelf initBeginAnnotation];
                }else if(type == AMapNaviRoutePlanPOITypeEnd){
                    weakSelf.endPoint = points[0];
                    [weakSelf initEndAnnotation];
                    if ( weakSelf.startPoint != nil) {
                        [weakSelf multipleRoutePlanAction];
                    }
                }else if(type == AMapNaviRoutePlanPOITypeWay){
                    weakSelf.wayPoints = [NSArray arrayWithArray:points];
                    [weakSelf initWayAnnotation];
                    if ( weakSelf.startPoint != nil&&weakSelf.endPoint != nil) {
                        [weakSelf multipleRoutePlanAction];
                    }
                }
                else if(type == 4){
                    NSDictionary * info  = points[0];
                    weakSelf.startPoint = [info objectForKey:@"startPoint"] ;
                    [weakSelf initBeginAnnotation];
                    weakSelf.endPoint = [info objectForKey:@"endPoint"] ;
                    [weakSelf initEndAnnotation];
                    weakSelf.wayPoints = [info objectForKey:@"wayPoints"] ;
                    [weakSelf initWayAnnotation];
                    if ( weakSelf.startPoint != nil&&weakSelf.endPoint != nil) {
                        [weakSelf multipleRoutePlanAction];
                    }
                }
            };
        _mapView.navigationRouteChangeBlock = ^(NSInteger routeID) {
                weakSelf.routeID = routeID;
                if (routeID>=0) {
                    [weakSelf selectNaviRouteWithID:routeID];
                }
            };
      
        
      
    }
    return _mapView;
    
}
-(dispatch_queue_t)methodQueue{
  //因为是显示页面，所以让原生接口运行在主线程
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;  // 请仅在您的模块初始化需要调用 UIKit 时才这样做！
}
#pragma mark - Initalization

-(NSMutableArray *)routeIndicatorInfoArray{
    if(!_routeIndicatorInfoArray){
        _routeIndicatorInfoArray = [NSMutableArray new];
    }
    return _routeIndicatorInfoArray;
}



- (void)multipleRoutePlanAction {
 
    //进行多路径规划
    self.isMultipleRoutePlan = YES;
    [[AMapNaviDriveManager sharedInstance] setMultipleRouteNaviMode:YES];
    NSLog(@"999888999=>%@",self.wayPoints);
    [[AMapNaviDriveManager sharedInstance] calculateDriveRouteWithStartPOIInfo:self.startPoint endPOIInfo:self.endPoint wayPOIInfos:self.wayPoints drivingStrategy:AMapNaviDrivingStrategyMultipleDefault];

}
-(void)initBeginAnnotation{
    
  
    
    if(_beginAnnotation){
        [self.mapView removeAnnotation:_beginAnnotation];
    }
    
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             // 这里是你想要延迟执行的代码
        weakSelf.beginAnnotation = [[NaviPointAnnotation alloc] init];
        [weakSelf.beginAnnotation setCoordinate:CLLocationCoordinate2DMake(weakSelf.startPoint.locPoint.latitude, weakSelf.startPoint.locPoint.longitude)];
        weakSelf.beginAnnotation.title = @"起始点";
        weakSelf.beginAnnotation.navPointType = NaviPointAnnotationStart;
        [weakSelf.mapView addAnnotation:weakSelf.beginAnnotation];
    });
    
}
- (void)initEndAnnotation {
    if(_endAnnotation){
        [self.mapView removeAnnotation:_endAnnotation];
    }
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             // 这里是你想要延迟执行的代码
     
        weakSelf.endAnnotation = [[NaviPointAnnotation alloc] init];
        [ weakSelf.endAnnotation setCoordinate:CLLocationCoordinate2DMake(weakSelf.endPoint.locPoint.latitude, weakSelf.endPoint.locPoint.longitude)];
        weakSelf.endAnnotation.title = @"终点";
        weakSelf.endAnnotation.navPointType = NaviPointAnnotationEnd;
        [weakSelf.mapView addAnnotation:weakSelf.endAnnotation];
    });
    
 
    
}

- (void)initWayAnnotation {
    if (_wayAnnotation != nil) {
        [self.mapView removeAnnotations:self.wayAnnotation];
    }
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             // 这里是你想要延迟执行的代码
      
        NSMutableArray * array = [NSMutableArray array];
        for(int i=0;i<weakSelf.wayPoints.count;i++)
        {
            AMapNaviPOIInfo *point = weakSelf.wayPoints[i];
            NaviPointAnnotation *  annotation = [[NaviPointAnnotation alloc] init];
            [annotation setCoordinate:CLLocationCoordinate2DMake(point.locPoint.latitude, point.locPoint.longitude)];
            annotation.title = [NSString stringWithFormat:@"%d",i+1];
            annotation.navPointType = NaviPointAnnotationWay;
            [array addObject:annotation];
            [weakSelf.mapView addAnnotation:annotation];
        }
        weakSelf.wayAnnotation = [NSArray arrayWithArray:array];
    });
    

    
}

- (void)dealloc {
    if(_mapView)
    {
         _mapView.delegate=nil;
         _mapView=nil;
    }
    BOOL success = [AMapNaviDriveManager destroyInstance];
    NSLog(@"单例是否销毁成功 : %d",success);
}


#pragma mark - Handle Navi Routes


- (void)selectNaviRouteWithID:(NSInteger)routeID {
    //在开始导航前进行路径选择
    if ([[AMapNaviDriveManager sharedInstance] selectNaviRouteWithRouteID:routeID])   {
//        AMapNaviRoute * rout =  [[AMapNaviDriveManager sharedInstance].naviRoutes objectForKey:@(routeID)];
//        if (rout) {
//         
//        }
       
        [self selecteOverlayWithRouteID:routeID];
    }   else    {
        NSLog(@"路径选择失败!");
    }
}

- (void)selecteOverlayWithRouteID:(NSInteger)routeID {
    
    NSMutableArray *selectedPolylines = [NSMutableArray array];
    CGFloat backupRoutePolylineWidthScale = 0.8;  //备选路线是当前路线宽度0.8
    
    [self.mapView.overlays enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<MAOverlay> overlay, NSUInteger idx, BOOL *stop) {
        
        if ([overlay isKindOfClass:[MultiDriveRoutePolyline class]]) {
             MultiDriveRoutePolyline *multiPolyline = overlay;
            
             /* 获取overlay对应的renderer. */
             MAMultiTexturePolylineRenderer * overlayRenderer = (MAMultiTexturePolylineRenderer *)[self.mapView rendererForOverlay:multiPolyline];

             if (multiPolyline.routeID == routeID) {
                 [selectedPolylines addObject:overlay];
             } else {
                 // 修改备选路线的样式
                 overlayRenderer.lineWidth = AMapNaviRoutePolylineDefaultWidth * backupRoutePolylineWidthScale;
                 overlayRenderer.strokeTextureImages = multiPolyline.polylineTextureImages;
             }
         }
     }];
    
    [self.mapView removeOverlays:selectedPolylines];
    [self.mapView addOverlays:selectedPolylines];
}

- (void)showMultiColorNaviRoutes {
    if ([[AMapNaviDriveManager sharedInstance].naviRoutes count] <= 0) {
        return;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeIndicatorInfoArray removeAllObjects];
    
    //将路径显示到地图上
    for (NSNumber *aRouteID in [[AMapNaviDriveManager sharedInstance].naviRoutes allKeys]) {
        AMapNaviRoute *aRoute = [[[AMapNaviDriveManager sharedInstance] naviRoutes] objectForKey:aRouteID];
        int count = (int)[[aRoute routeCoordinates] count];
        //添加路径Polyline
        CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < count; i++) {
            AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
            coords[i].latitude = [coordinate latitude];
            coords[i].longitude = [coordinate longitude];
        }
        
        NSMutableArray<UIImage *> *textureImagesArrayNormal = [NSMutableArray new];
        NSMutableArray<UIImage *> *textureImagesArraySelected = [NSMutableArray new];
        
        // 添加路况图片
        for (AMapNaviTrafficStatus *status in aRoute.routeTrafficStatuses) {
            UIImage *img = [self defaultTextureImageForRouteStatus:status.status isSelected:NO];
            UIImage *selImg = [self defaultTextureImageForRouteStatus:status.status isSelected:YES];
            if (img && selImg) {
                [textureImagesArrayNormal addObject:img];
                [textureImagesArraySelected addObject:selImg];
            }
        }
        
        MultiDriveRoutePolyline *mulPolyline = [MultiDriveRoutePolyline polylineWithCoordinates:coords count:count drawStyleIndexes:aRoute.drawStyleIndexes];
        mulPolyline.polylineTextureImages = textureImagesArrayNormal;
        mulPolyline.polylineTextureImagesSeleted = textureImagesArraySelected;
        mulPolyline.routeID = aRouteID.integerValue;
        
        [self.mapView addOverlay:mulPolyline];
        free(coords);
  
        //更新CollectonView的信息
        RouteCollectionViewInfo *info = [[RouteCollectionViewInfo alloc] init];
        info.routeID = [aRouteID integerValue];
        info.title = [NSString stringWithFormat:@"路径ID:%ld | 路径计算策略:%ld (点击展示路线详情)", (long)[aRouteID integerValue], (long)[self.preferenceView strategyWithIsMultiple:self.isMultipleRoutePlan]];
        info.subtitle = [NSString stringWithFormat:@"长度:%ld米 | 预估时间:%ld秒 | 分段数:%ld", (long)aRoute.routeLength, (long)aRoute.routeTime, (long)aRoute.routeSegments.count];
        
        [self.routeIndicatorInfoArray addObject:info];
    }
    self.mapView.routes = [[AMapNaviDriveManager sharedInstance].naviRoutes allValues];
    
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    [self.routeIndicatorView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             // 这里是你想要延迟执行的代码
        [self selectNaviRouteWithID:[[self.routeIndicatorInfoArray firstObject] routeID]];
    });
   
}

//根据交通状态获得纹理图片
- (UIImage *)defaultTextureImageForRouteStatus:(AMapNaviRouteStatus)routeStatus isSelected:(BOOL)isSelected {
    
    NSString *imageName = nil;
    
    if (routeStatus == AMapNaviRouteStatusSmooth) {
        imageName = @"custtexture_green";
    } else if (routeStatus == AMapNaviRouteStatusSlow) {
        imageName = @"custtexture_slow";
    } else if (routeStatus == AMapNaviRouteStatusJam) {
        imageName = @"custtexture_bad";
    } else if (routeStatus == AMapNaviRouteStatusSeriousJam) {
        imageName = @"custtexture_serious";
    } else {
        imageName = @"custtexture_no";
    }
    if (!isSelected) {
        imageName = [NSString stringWithFormat:@"%@_unselected",imageName];
    }
    
    return [UIImage imageNamed:imageName];
}

#pragma mark - Data Source

- (void)buildRouteDataSource {
    NSMutableArray *routeDataArray = @[].mutableCopy;
    for (NSNumber *routeID in [AMapNaviDriveManager sharedInstance].naviRoutes) {
        //获取每条路线
        AMapNaviRoute *route = [[AMapNaviDriveManager sharedInstance].naviRoutes objectForKey:routeID];
        //获取路线详情数据模型
        NSArray *aRouteData = [self buildExtendGroupSegmentForRoute:route wayPointNames:nil];
        if (aRouteData.count) {
            [routeDataArray addObject:aRouteData];
        }
    }
    self.routeDataSource = routeDataArray.copy;
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error {
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteSuccessWithType:(AMapNaviRoutePlanType)type
{
    NSLog(@"onCalculateRouteSuccess");
    
    //算路成功后显示路径
    [self showMultiColorNaviRoutes];
    
    //构建路线数据模型
//    [self buildRouteDataSource];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error routePlanType:(AMapNaviRoutePlanType)type
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");

  

}
- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{

    NSLog(@"didEndEmulatorNavi");
}
- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForTrafficJam");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onArrivedWayPoint:(int)wayPointIndex
{
    NSLog(@"onArrivedWayPoint:%d", wayPointIndex);
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



- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onArrivedDestination");
}



#pragma mark - MAMapView Delegate
/**
 * @brief 地图加载失败
 * @param mapView 地图View
 * @param error 错误信息
 */
- (void)mapViewDidFailLoadingMap:(MAMapView *)mapView withError:(NSError *)error{
    NSLog(@"didEndeeee");
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[NaviPointAnnotation class]])
    {
//        static NSString *annotationIdentifier = @"NaviPointAnnotationIdentifier";
//        
//        MAPinAnnotationView *pointAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
//        if (pointAnnotationView == nil)
//        {
        MAPinAnnotationView *pointAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:nil];

        pointAnnotationView.animatesDrop   = NO;
        pointAnnotationView.canShowCallout = YES;
        pointAnnotationView.draggable      = NO;
        
        NaviPointAnnotation *navAnnotation = (NaviPointAnnotation *)annotation;
        
        if (navAnnotation.navPointType == NaviPointAnnotationStart)
        {
             pointAnnotationView.image = [UIImage imageNamed:@"startIcon"];
        }
        else if (navAnnotation.navPointType == NaviPointAnnotationEnd)
        {
            pointAnnotationView.image = [UIImage imageNamed:@"endIcon"];
        }else if (navAnnotation.navPointType == NaviPointAnnotationWay)
        {
            if(navAnnotation.title.length != 0)
            {
                UILabel* lable = [[UILabel alloc]init];
                lable.center  = pointAnnotationView.center;
                lable.frame =CGRectMake(0, 0, 25, 30);
                lable.text =navAnnotation.title;
                lable.textAlignment = NSTextAlignmentCenter;
                lable.textColor = [UIColor whiteColor];
                lable.font =[UIFont systemFontOfSize:14];
                [pointAnnotationView addSubview:lable];
               
            }
            pointAnnotationView.image = [UIImage imageNamed:@"wayIcon"];
        }
        
        return pointAnnotationView;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[SelectableOverlay class]]) {
        SelectableOverlay * selectableOverlay = (SelectableOverlay *)overlay;
        id<MAOverlay> actualOverlay = selectableOverlay.overlay;
        
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
        
        polylineRenderer.lineWidth = 8.f;
        polylineRenderer.strokeColor = selectableOverlay.isSelected ? selectableOverlay.selectedColor : selectableOverlay.regularColor;
  
        return polylineRenderer;
    } else if ([overlay isKindOfClass:[MultiDriveRoutePolyline class]]) {
        MultiDriveRoutePolyline *mpolyline = (MultiDriveRoutePolyline *)overlay;
        MAMultiTexturePolylineRenderer *polylineRenderer = [[MAMultiTexturePolylineRenderer alloc] initWithMultiPolyline:mpolyline];
        
        polylineRenderer.lineWidth = AMapNaviRoutePolylineDefaultWidth;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.strokeTextureImages = mpolyline.polylineTextureImagesSeleted;
        
        
        [self.mapView setVisibleMapRect:mpolyline.boundingMapRect edgePadding:UIEdgeInsetsMake(140, 40, 200, 40) animated:NO];
        
        
        return polylineRenderer;
        
    }
    
    return nil;
}


#pragma mark - Utils

- (NSArray <RouteGroupSegmentModel *> *)buildExtendGroupSegmentForRoute:(AMapNaviRoute *)aRoute wayPointNames:(NSArray <NSString *>*)wayPointNames {
    if (aRoute == nil || [[aRoute routeGroupSegments] count] <= 0 || aRoute.routeSegmentCount <= 0) {
        return nil;
    }
    
    int wapPointIndex = 0;
    
    NSMutableArray <RouteGroupSegmentModel *> *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < aRoute.routeGroupSegments.count; i++) {
        @autoreleasepool {
            AMapNaviGroupSegment *aGroupSegment = [aRoute.routeGroupSegments objectAtIndex:i];
            RouteGroupSegmentModel *aExtendGroupSegment = [[RouteGroupSegmentModel alloc] init];
            
            int trafficLightCount = 0;
            NSMutableArray <RouteSegmentDetailModel *> *extendSegments = [[NSMutableArray alloc] init];
            
            for (NSInteger j = aGroupSegment.startSegmentID; j < aGroupSegment.startSegmentID+aGroupSegment.segmentCount; j++)  {
                AMapNaviSegment *aSegment = [aRoute.routeSegments objectAtIndex:j];
                RouteSegmentDetailModel *aExtendSegment = [[RouteSegmentDetailModel alloc] init];
                
                [aExtendSegment setIconType:aSegment.iconType];
                [aExtendSegment setIsArriveWayPoint:aSegment.isArriveWayPoint];
                
                //detailedDescription
                if (j+1 >= aRoute.routeSegmentCount) {
                    NSString *detailString = [NSString stringWithFormat:@"行驶%@%@到达终点",
                                              [self normalizedRemainDistance:aSegment.length],
                                              [self descriptionForIconType:aSegment.iconType]];
                    [aExtendSegment setDetailedDescription:detailString];
                    
                    //modify iconType
                    [aExtendSegment setIconType:AMapNaviIconTypeStraight];
                } else {
                    if (aSegment.isArriveWayPoint) {
                        if (wapPointIndex < [wayPointNames count]) {
                            [aExtendSegment setDetailedDescription:[NSString stringWithFormat:@"到达途经点 %@", [wayPointNames objectAtIndex:wapPointIndex]]];
                            ++wapPointIndex;
                        } else {
                            [aExtendSegment setDetailedDescription:@"到达途经点"];
                        }
                    } else {
                        AMapNaviSegment *nextSegment = [aRoute.routeSegments objectAtIndex:j+1];
                        
                        NSString *detailString = [NSString stringWithFormat:@"行驶%@%@进入%@",
                                                  [self normalizedRemainDistance:aSegment.length],
                                                  [self descriptionForIconType:aSegment.iconType],
                                                  [[[nextSegment links] firstObject] roadName]];
                        [aExtendSegment setDetailedDescription:detailString];
                    }
                }
                
                //trafficLightCount
                trafficLightCount += aSegment.trafficLightCount;
                
                [extendSegments addObject:aExtendSegment];
            }
            
            [aExtendGroupSegment setExtendSegments:extendSegments];
            [aExtendGroupSegment setGroupName:aGroupSegment.groupName];
            [aExtendGroupSegment setDistance:aGroupSegment.distance];
            [aExtendGroupSegment setTrafficLightCount:trafficLightCount];
            
            //modify iconType
            [aExtendGroupSegment setIconType:[[aRoute.routeSegments objectAtIndex:aGroupSegment.startSegmentID] iconType]];
            if (aExtendGroupSegment.iconType == AMapNaviIconTypeArrivedWayPoint || aExtendGroupSegment.iconType == AMapNaviIconTypeArrivedDestination)
            {
                [aExtendGroupSegment setIconType:AMapNaviIconTypeStraight];
            }
            
            [result addObject:aExtendGroupSegment];
        }//autoreleasepool
    }
    
    return result;
}

- (NSString *)descriptionForIconType:(AMapNaviIconType)iconType {
    static NSDictionary *mappings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mappings = @{@(AMapNaviIconTypeNone): @"",
                     @(AMapNaviIconTypeDefault): @"",
                     @(AMapNaviIconTypeLeft): @"左转",
                     @(AMapNaviIconTypeRight): @"右转",
                     @(AMapNaviIconTypeLeftFront): @"向左前方转",
                     @(AMapNaviIconTypeRightFront): @"向右前方转",
                     @(AMapNaviIconTypeLeftBack): @"向左后转",
                     @(AMapNaviIconTypeRightBack): @"向右后转",
                     @(AMapNaviIconTypeLeftAndAround): @"左转掉头",
                     @(AMapNaviIconTypeStraight): @"直行",
                     @(AMapNaviIconTypeArrivedWayPoint) : @"",
                     @(AMapNaviIconTypeEnterRoundabout) : @"进入环岛",
                     @(AMapNaviIconTypeOutRoundabout): @"驶出环岛",
                     @(AMapNaviIconTypeArrivedServiceArea): @"",
                     @(AMapNaviIconTypeArrivedTollGate): @"",
                     @(AMapNaviIconTypeArrivedDestination): @"直行",
                     @(AMapNaviIconTypeArrivedTunnel): @"",
                     @(AMapNaviIconTypeCrosswalk): @"",
                     @(AMapNaviIconTypeFlyover): @"",
                     @(AMapNaviIconTypeUnderpass): @""
                     };
    });
    
    NSString *description = [mappings objectForKey:@(iconType)];
    if (description == nil) {
        description = [mappings objectForKey:@(AMapNaviIconTypeNone)];
    }
    
    return description;
}

- (nullable NSString *)normalizedRemainDistance:(NSInteger)remainDistance {
    if (remainDistance < 0) {
        return nil;
    }
    
    if (remainDistance >= 1000) {
        NSString *distStr = [NSString stringWithFormat:@"%.1f公里",remainDistance/1000.0];
        return distStr;
    } else {
        return [NSString stringWithFormat:@"%ld米", (long)remainDistance];
    }
}

@end
