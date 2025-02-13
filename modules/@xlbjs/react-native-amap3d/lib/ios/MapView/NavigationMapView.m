//
//  NavigationMapManger.m
//  react-native-amap3d
//
//  Created by 杨礼正 on 2024/8/7.
//

#import "NavigationMapView.h"
#import "RCTConvert+CoreLocation.h"
@implementation NavigationMapView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//@property (nonatomic, strong) AMapNaviPoint *startPoint;
//@property (nonatomic, strong) AMapNaviPoint *endPoint;
//@property (nonatomic, strong) NSArray <AMapNaviPoint *> *wayPoints;
//
//@property (nonatomic, assign) NSInteger routeID;
-(void)setStartPoint:(NSDictionary *)startPoint{
    _startPoint = startPoint;
    AMapNaviPOIInfo * newPoint =  [NavigationMapView getAMapNaviPOIInfo:startPoint];
    if(self.navigationMapBlock){
        self.navigationMapBlock(AMapNaviRoutePlanPOITypeStart, @[newPoint]);
    }
}
-(void)setEndPoint:(NSDictionary *)endPoint{
    _endPoint = endPoint;
    AMapNaviPOIInfo * newPoint =  [NavigationMapView getAMapNaviPOIInfo:endPoint];
    if(self.navigationMapBlock){
        self.navigationMapBlock(AMapNaviRoutePlanPOITypeEnd, @[newPoint]);
    }
}
-(void)setWayPoints:(NSArray<NSDictionary *> *)wayPoints{
    _wayPoints = wayPoints;
    
    if(self.navigationMapBlock){
        self.navigationMapBlock(AMapNaviRoutePlanPOITypeWay, [NavigationMapView getAMapNaviPOIInfos:wayPoints]);
    }
}
-(void)setPoints:(NSDictionary *)points{
    _points = points;
    
    if (points != nil && ([points allKeys].count > 0)) {
        if(self.navigationMapBlock){
            self.navigationMapBlock(4, [NavigationMapView getAMapNaviPOIInfosWithPoints:points]);
        }
    }
   
}
-(void)setRouteID:(NSInteger)routeID{
    if(routeID == 0&&_routeID == 0){
        
    }else{
        _routeID = routeID;
        if(self.navigationRouteChangeBlock){
            self.navigationRouteChangeBlock(routeID);
        }
    }
   
}


+(NSDictionary *)getAMapNaviPOIInfosWithPoints:(NSDictionary *)points{
    
    return @[@{
        @"startPoint":[NavigationMapView getAMapNaviPOIInfo:[points objectForKey:@"startPoint"]],
        @"endPoint":[NavigationMapView getAMapNaviPOIInfo:[points objectForKey:@"endPoint"]],
        @"wayPoints":[NavigationMapView getAMapNaviPOIInfos:[points objectForKey:@"wayPoints"]],
    }];
}


+(NSArray *)getAMapNaviPOIInfos:(NSArray *)array{
    
    NSMutableArray * new = [NSMutableArray array];
    for (NSDictionary * dic in array) {
        [new addObject:[NavigationMapView getAMapNaviPOIInfo:dic]];
    }
    return new;

    
}

-(void)setRoutes:(NSArray<AMapNaviRoute*> *)routes{
    _routes = routes;
    if (self.onCalculateRouteSuccess) {
        
        NSMutableArray * array = [NSMutableArray array];
        for (int i=0; i<routes.count; i++) {
            AMapNaviRoute * rout =routes[i];
            NSDictionary * dic =@{
                @"routId":@(rout.routeUID),
                @"routeTime":@(rout.routeTime),
                @"routeLength":@(rout.routeLength),
                @"routeTrafficLightCount":@(rout.routeTrafficLightCount)
                
            };
            [array addObject:dic];
        }
        
        self.onCalculateRouteSuccess(@{@"routes":[NSArray arrayWithArray:array]});
    }
}
+(AMapNaviPOIInfo *)getAMapNaviPOIInfo:(NSDictionary *)dic{

    AMapNaviPOIInfo * info =  [AMapNaviPOIInfo new];
    info.mid = [dic objectForKey:@"id"];
    info.locPoint = [NavigationMapView getAMapNaviPoint:[dic objectForKey:@"position"]];
    return info;
}
+(AMapNaviPoint *)getAMapNaviPoint:(NSDictionary *)dic{
    AMapNaviPoint * info =  [AMapNaviPoint new];
    info.latitude = [[dic objectForKey:@"latitude"] doubleValue];
    info.longitude =  [[dic objectForKey:@"longitude"] doubleValue];
    return info;
}


@end
