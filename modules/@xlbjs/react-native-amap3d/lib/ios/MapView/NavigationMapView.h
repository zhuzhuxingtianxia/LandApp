//
//  NavigationMapManger.h
//  react-native-amap3d
//
//  Created by 杨礼正 on 2024/8/7.
//


#import <AMapNaviKit/AMapNaviKit.h>
#import <React/RCTComponent.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^NavigationMapBlock)(NSInteger  type,NSArray * points);
typedef void(^NavigationRouteChangeBlock)(NSInteger routeID);

@interface NavigationMapView : MAMapView
@property (nonatomic, copy) RCTBubblingEventBlock onCalculateRouteSuccess;
@property (nonatomic, copy) NavigationMapBlock navigationMapBlock;
@property (nonatomic, copy) NavigationRouteChangeBlock navigationRouteChangeBlock;

@property (nonatomic, strong) NSDictionary *startPoint;
@property (nonatomic, strong) NSDictionary *endPoint;
@property (nonatomic, strong) NSArray <NSDictionary *> *wayPoints;
@property (nonatomic, strong) NSDictionary *points;
@property (nonatomic, assign) NSInteger routeID;
@property (nonatomic, strong) NSArray * routes;

@end

NS_ASSUME_NONNULL_END
