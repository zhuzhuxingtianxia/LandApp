//
//  DriveRouteDataMode.h
//  DevDemoNavi
//
//  Created by whj on 2019/4/9.
//  Copyright © 2019 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AMapNaviKit/AMapNaviKit.h>


#pragma mark - RouteSegmentDetailModel

@interface RouteSegmentDetailModel : NSObject

@property (nonatomic, assign) AMapNaviIconType iconType;

@property (nonatomic, strong) NSString *detailedDescription;

@property (nonatomic, assign) BOOL isArriveWayPoint;

@end

#pragma mark - RouteGroupSegmentModel

@interface RouteGroupSegmentModel : NSObject

//驾车下表示GroupName，骑行下被当做'detailedDescription'使用
@property (nonatomic, strong) NSString *groupName;

@property (nonatomic, assign) NSInteger distance;

@property (nonatomic, assign) AMapNaviIconType iconType;

@property (nonatomic, assign) NSInteger trafficLightCount;

@property (nonatomic, strong) NSArray <RouteSegmentDetailModel *> *extendSegments;

@end
