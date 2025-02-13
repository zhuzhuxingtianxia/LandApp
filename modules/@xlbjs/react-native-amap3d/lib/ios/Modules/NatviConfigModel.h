//
//  NatviConfigModel.h
//  BVLinearGradient
//
//  Created by 杨礼正 on 2024/8/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NatviConfigModel : NSObject
@property (nonatomic, assign) int type;
@property (nonatomic, assign) CGFloat lat;
@property (nonatomic, assign) CGFloat lon;
@property (nonatomic, copy)   NSString * name;
@property (nonatomic, copy)   NSString * POIId;

-(NatviConfigModel *)initWithDic:(NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END
