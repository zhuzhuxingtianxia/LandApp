//
//  NatviConfigModel.m
//  BVLinearGradient
//
//  Created by 杨礼正 on 2024/8/5.
//

#import "NatviConfigModel.h"

@implementation NatviConfigModel
-(NatviConfigModel *)initWithDic:(NSDictionary *)data{

    self = [super init];
    if (self != nil) {
        self.type = [[data objectForKey:@"type"] intValue];
        self.lat = [[data objectForKey:@"lat"] floatValue];
        self.lon = [[data objectForKey:@"lon"] floatValue];
        self.name = [data objectForKey:@"name"];
        self.POIId = [data objectForKey:@"POIId"];
    }

    return self;
}
@end
