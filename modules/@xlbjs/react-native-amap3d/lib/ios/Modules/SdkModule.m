#import <React/RCTBridgeModule.h>
#import <AMapLocationKit/AMapLocationManager.h>


@interface RCT_EXTERN_MODULE(AMapSdk, NSObject)

RCT_EXTERN_METHOD(initSDK: (NSString)apiKey)
RCT_EXTERN_METHOD(getVersion: (RCTPromiseResolveBlock)resolve reject: (RCTPromiseRejectBlock)_)
RCT_EXTERN_METHOD(getLocation: (BOOL)hasReGeocode resolve:(RCTPromiseResolveBlock)resolve reject: (RCTPromiseRejectBlock)_)
RCT_EXTERN_METHOD(getSystemLocation: (RCTPromiseResolveBlock)resolve reject: (RCTPromiseRejectBlock)_)
RCT_EXTERN_METHOD(reverseGeocode: (NSDictionary *)point resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(poiSearch: (NSDictionary *)params resolve:(RCTPromiseResolveBlock)resolve reject: (RCTPromiseRejectBlock)_)

@end
