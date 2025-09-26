#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <React/RCTImageLoader.h>
#import "ReactNativeAmap3d-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarkerComponentView : RCTViewComponentView

@end

NS_ASSUME_NONNULL_END


@class MapView;

@interface AMapViewManager : RCTViewManager

@end

@protocol Overlay <NSObject>

@required
- (MABaseOverlay *)getOverlay;
- (MAOverlayRenderer *)getRenderer;

@end

@class MarkerView;

@interface MapView : MAMapView

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, strong) RCTImageLoader *imageLoader;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIView*> *overlayMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *markerMap;
@property (nonatomic, strong) NSDictionary *locationImageData;
@property (nonatomic, strong) MAUserLocationRepresentation *locationRender;
@property (nonatomic, strong) MAAnnotationView *locationAnnotationView;

// 事件回调block
@property (nonatomic, copy) RCTBubblingEventBlock onLoad;
@property (nonatomic, copy) RCTBubblingEventBlock onCameraMove;
@property (nonatomic, copy) RCTBubblingEventBlock onCameraIdle;
@property (nonatomic, copy) RCTBubblingEventBlock onPress;
@property (nonatomic, copy) RCTBubblingEventBlock onPressPoi;
@property (nonatomic, copy) RCTBubblingEventBlock onLongPress;
@property (nonatomic, copy) RCTBubblingEventBlock onLocation;
@property (nonatomic, copy) RCTBubblingEventBlock onCallback;

// 属性设置
@property (nonatomic, assign) BOOL hideLogo;
@property (nonatomic, strong) NSDictionary<NSString *, id> *customStyleOptions;
@property (nonatomic, assign) BOOL accuracyRingEnabled;
@property (nonatomic, assign) BOOL headingIndicatorEnabled;
@property (nonatomic, strong) UIColor *accuracyRingFillColor;
@property (nonatomic, assign) CGFloat accuracyRingLineWidth;
@property (nonatomic, strong) UIColor *accuracyRingStokrColor;
@property (nonatomic, assign) BOOL pulseAnnimationEnable;
@property (nonatomic, strong) UIColor *locationDotBgColor;
@property (nonatomic, strong) UIColor *locationDotFillColor;
@property (nonatomic, strong) NSDictionary *locationImage;

- (void)setLocationIcon:(NSDictionary *)locationI;
- (void)loadRender;
- (void)loadImage;
- (void)setInitialCameraPosition:(NSDictionary *)json;
- (void)moveCamera:(NSDictionary *)position duration:(NSInteger)duration;
- (void)callWithId:(double)callerId name:(NSString *)name args:(NSDictionary *)args;
- (void)callback:(double)callerId data:(NSDictionary *)data;

@end

// MAAnnotationView的分类
@interface MAAnnotationView (Rotation)

- (void)rotateWithHeading:(CLHeading *)heading;

@end
