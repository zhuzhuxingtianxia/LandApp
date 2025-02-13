//
//  NavigationViewController.h
//  react-native-amap3d
//
//  Created by 杨礼正 on 2024/8/7.
//

#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>
NS_ASSUME_NONNULL_BEGIN

@interface NavigationCustomViewManager : RCTViewManager

+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
