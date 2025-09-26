//
//  MarkerComponentView.m
//  react-native-amap3d
//
//  Created by hil on 2025/8/22.
//

#import "MarkerComponentView.h"
#import <CoreLocation/CoreLocation.h>
#import <react/renderer/components/AMapSpec/RCTComponentViewHelpers.h>
#import <react/renderer/components/AMapSpec/ComponentDescriptors.h>
#import <react/renderer/components/AMapSpec/EventEmitters.h>
#import <react/renderer/components/AMapSpec/Props.h>
#import "RCTFabricComponentsPlugins.h"


#import <React/RCTUIManager.h>

using namespace facebook::react;

@interface MarkerComponentView () <RCTMapMarkerViewProtocol>
@property(nonatomic, assign)CLLocationCoordinate2D latLng;
@property(nonatomic, assign)CGPoint centerOffset;
@property(nonatomic, assign)Boolean draggable;
@property(nonatomic, assign)NSInteger zIndex;
@property(nonatomic, strong)NSDictionary *icon;
@property(nonatomic, strong)UIImage *iconImage;

@property(nonatomic, strong)MAAnimatedAnnotation *annotation;
@property(nonatomic,strong)MAAnnotationView *annotationView;

@property(nonatomic, assign)RCTDirectEventBlock onPress;
@property(nonatomic, assign)RCTDirectEventBlock onDragStart;
@property(nonatomic, assign)RCTDirectEventBlock onDrag;
@property(nonatomic, assign)RCTDirectEventBlock onDragEnd;

-(void)reciveEventName:(NSString*)name data: (NSDictionary*)data;

@end

@implementation MarkerComponentView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const MapMarkerProps>();

    _props = defaultProps;
    self.contentView = [[UIView alloc] init];
      
    self.annotation = [[MAAnimatedAnnotation alloc] init];
  }

  return self;
}

# pragma 子组件需要处理
- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index {
    // 将子视图添加到容器视图
    [self.contentView addSubview:childComponentView];
}

-(void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index {
    [childComponentView removeFromSuperview];
}

# pragma-- Codegen 需要实现以下三个方法

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<MapMarkerComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<MapMarkerProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<MapMarkerProps const>(props);

    if (oldViewProps.position.latitude != newViewProps.position.latitude ||
        oldViewProps.position.longitude != newViewProps.position.longitude
        ) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(newViewProps.position.latitude, newViewProps.position.longitude);
        self.latLng = coordinate;
        self.annotation.coordinate = coordinate;
    }
    
    if (oldViewProps.centerOffset.x != newViewProps.centerOffset.x ||
        oldViewProps.centerOffset.y != newViewProps.centerOffset.y
        ) {
        CGPoint point = CGPointMake(newViewProps.centerOffset.x, newViewProps.centerOffset.y);
        self.centerOffset = point;
    }
    
    if(oldViewProps.draggable != newViewProps.draggable) {
        self.draggable = newViewProps.draggable;
    }
    if(oldViewProps.markerIndex != newViewProps.markerIndex) {
        self.zIndex = NSInteger(newViewProps.markerIndex);
    }
    
    if(oldViewProps.icon != newViewProps.icon) {
        NSDictionary *icon =  @{
            @"width": @(newViewProps.icon.size.width),
            @"height": @(newViewProps.icon.size.height),
            @"uri": [[NSString alloc] initWithUTF8String: newViewProps.icon.uri.c_str()],
        };
        self.icon = icon;
    }
    
    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> MapMarkerCls(void)
{
    return MarkerComponentView.class;
}

# pragma-- Event emitter convenience method
- (const MapMarkerEventEmitter &)eventEmitter
{
  return static_cast<const MapMarkerEventEmitter &>(*_eventEmitter);
}

-(void)reciveEventName:(NSString*)name data: (NSDictionary*)data {
    if([name isEqualToString:@"onPress"]) {
        self.eventEmitter.onPress({});
    }else if ([name isEqualToString:@"onDragStart"]) {
//        self.eventEmitter.onDragStart({});
    }else if ([name isEqualToString:@"onDrag"]) {
//        self.eventEmitter.onDrag({});
    }else if ([name isEqualToString:@"onDragEnd"]) {
//        self.eventEmitter.onDragEnd({latitude: data[@"latitude"], longitude: data[@"longitude"]});
    }
    
}

#pragma RCTMapMarkerViewProtocol
-(void)update {
    if(self.contentView) {
        NSLog(@"update 没有用到");
    }
}

@end

//-----------------------------------

@interface AMapViewManager()
@property(nonatomic,strong)MapView *mapview;
@end

@implementation AMapViewManager
RCT_EXPORT_MODULE(AMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, MAMapType)
RCT_EXPORT_VIEW_PROPERTY(initialCameraPosition, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(distanceFilter, double)
RCT_EXPORT_VIEW_PROPERTY(headingFilter, double)
RCT_EXPORT_VIEW_PROPERTY(hideLogo, BOOL)
RCT_EXPORT_VIEW_PROPERTY(customStyleOptions, NSDictionary)

RCT_REMAP_VIEW_PROPERTY(myLocationEnabled, showsUserLocation, BOOL)
RCT_REMAP_VIEW_PROPERTY(buildingsEnabled, showsBuildings, BOOL)
RCT_REMAP_VIEW_PROPERTY(trafficEnabled, showTraffic, BOOL)
RCT_REMAP_VIEW_PROPERTY(indoorViewEnabled, showsIndoorMap, BOOL)
RCT_REMAP_VIEW_PROPERTY(compassEnabled, showsCompass, BOOL)
RCT_REMAP_VIEW_PROPERTY(scaleControlsEnabled, showsScale, BOOL)
RCT_REMAP_VIEW_PROPERTY(scrollGesturesEnabled, scrollEnabled, BOOL)
RCT_REMAP_VIEW_PROPERTY(zoomGesturesEnabled, zoomEnabled, BOOL)
RCT_REMAP_VIEW_PROPERTY(rotateGesturesEnabled, rotateEnabled, BOOL)
RCT_REMAP_VIEW_PROPERTY(tiltGesturesEnabled, rotateCameraEnabled, BOOL)
RCT_REMAP_VIEW_PROPERTY(minZoom, minZoomLevel, double)
RCT_REMAP_VIEW_PROPERTY(maxZoom, maxZoomLevel, double)

RCT_EXPORT_VIEW_PROPERTY(accuracyRingEnabled, BOOL);
RCT_EXPORT_VIEW_PROPERTY(headingIndicatorEnabled, BOOL);
RCT_EXPORT_VIEW_PROPERTY(accuracyRingFillColor, UIColor);
RCT_EXPORT_VIEW_PROPERTY(accuracyRingStokrColor, UIColor);
RCT_EXPORT_VIEW_PROPERTY(accuracyRingLineWidth, double);
RCT_EXPORT_VIEW_PROPERTY(pulseAnnimationEnable, BOOL);
RCT_EXPORT_VIEW_PROPERTY(locationDotBgColor, UIColor);
RCT_EXPORT_VIEW_PROPERTY(locationDotFillColor, UIColor);
RCT_EXPORT_VIEW_PROPERTY(locationImage, NSDictionary);

RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPressPoi, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLongPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCameraIdle, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCameraMove, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoad, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLocation, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCallback, RCTBubblingEventBlock)

RCT_EXTERN_METHOD(moveCamera:(nonnull NSNumber *)reactTag position:(NSDictionary *)_ duration:(int)_)
RCT_EXTERN_METHOD(call:(nonnull NSNumber *)reactTag callerId:(double)_ name:(NSString *)_ args:(NSDictionary *)_)

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (UIView *)view {
  MapView *view = [[MapView alloc] init];
  view.imageLoader = (RCTImageLoader *)[self.bridge moduleForName:@"ImageLoader"];
  NSLog(@"load");
  self.mapview = view;
  return view;
}

-(void)dealloc {
    NSLog(@"AMapViewManager dealloc");
}

- (void)moveCamera:(NSNumber *)reactTag position:(NSDictionary *)position duration:(NSInteger)duration {
  [self getViewWithReactTag:reactTag callback:^(MapView *view) {
    if (view) {
      [view moveCamera:position duration:duration];
    }
  }];
}

- (void)call:(NSNumber *)reactTag callerId:(double)callerId name:(NSString *)name args:(NSDictionary *)args {
  [self getViewWithReactTag:reactTag callback:^(MapView *view) {
    if (view) {
      [view callWithId:callerId name:name args:args];
    }
  }];
}

- (void)getViewWithReactTag:(NSNumber *)reactTag callback:(void (^)(MapView * _Nullable))callback {
    
    UIView *view = [self.bridge.uiManager viewForReactTag:reactTag];
    
    if (!view) {
        callback(self.mapview);
        return;
    }
    
    if ([view isKindOfClass:[MapView class]]) {
        callback((MapView *)view);
    } else {
        callback(nil);
    }
}

@end

@interface MapView()<MAMapViewDelegate>
{
    UIImage *locationIcon;
}
@end

@implementation MapView

- (instancetype)init {
  self = [super init];
  if (self) {
    _initialized = NO;
    _overlayMap = [NSMutableDictionary dictionary];
    _markerMap = [NSMutableDictionary dictionary];
    _locationRender = [[MAUserLocationRepresentation alloc] init];

    // 初始化默认属性值
    _accuracyRingFillColor = [UIColor whiteColor];
    _accuracyRingLineWidth = 1.0;
    _accuracyRingStokrColor = [UIColor blackColor];
    _locationDotBgColor = [UIColor blackColor];
    _locationDotFillColor = [UIColor whiteColor];
      
      _onLoad = ^(NSDictionary *body){};
      _onCameraMove = ^(NSDictionary *body){};
      _onCameraIdle = ^(NSDictionary *body){};
      _onPress = ^(NSDictionary *body){};
      _onPressPoi = ^(NSDictionary *body){};
      _onLongPress = ^(NSDictionary *body){};
      _onLocation = ^(NSDictionary *body){};
      _onCallback = ^(NSDictionary *body){};

      __weak id weakSelf = self;
      self.delegate = weakSelf;
  }
  return self;
}

-(void)dealloc {
    NSLog(@"MapView dealloc");
}

#pragma mark - Property Setters

- (void)setHideLogo:(BOOL)hideLogo {
  _hideLogo = hideLogo;
  CGSize logoSize = self.logoSize;
  UIView *logoView = nil;
  for (UIView *subView in self.subviews) {
    if ([subView isKindOfClass:[UIImageView class]] && CGSizeEqualToSize(subView.bounds.size, logoSize)) {
      logoView = subView;
      break;
    }
  }
  logoView.hidden = hideLogo;
  logoView.alpha = hideLogo ? 0 : 1.0;
}

- (void)setCustomStyleOptions:(NSDictionary<NSString *,id> *)customStyleOptions {
  _customStyleOptions = customStyleOptions;
  if (customStyleOptions && customStyleOptions.count == 0) {
    self.customMapStyleEnabled = NO;
    return;
  }

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    MAMapCustomStyleOptions *options = [[MAMapCustomStyleOptions alloc] init];

    // 处理 styleData
    NSDictionary *styleData = customStyleOptions[@"styleData"];
    if (styleData) {
      NSString *uriString = styleData[@"uri"];
      if (uriString) {
        NSURL *url = [NSURL URLWithString:uriString];
        if (url) {
          NSError *error = nil;
          NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
          if (data) {
            options.styleData = data;
          } else {
            NSLog(@"加载 styleData 失败: %@", error);
          }
        }
      }
    }

    // 处理 styleExtraData
    NSDictionary *styleExtraData = customStyleOptions[@"styleExtraData"];
    if (styleExtraData) {
      NSString *uriString = styleExtraData[@"uri"];
      if (uriString) {
        NSURL *url = [NSURL URLWithString:uriString];
        if (url) {
          NSError *error = nil;
          NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
          if (data) {
            options.styleExtraData = data;
          } else {
            NSLog(@"加载 styleExtraData 失败: %@", error);
          }
        }
      }
    }

    // 处理 styleTextureData
    NSDictionary *styleTextureData = customStyleOptions[@"styleTextureData"];
    if (styleTextureData) {
      NSString *uriString = styleTextureData[@"uri"];
      if (uriString) {
        NSURL *url = [NSURL URLWithString:uriString];
        if (url) {
          NSError *error = nil;
          NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
          if (data) {
            options.styleTextureData = data;
          } else {
            NSLog(@"加载 styleTextureData 失败: %@", error);
          }
        }
      }
    }

    // 处理 styleId
    NSString *styleId = customStyleOptions[@"styleId"];
    if (styleId) {
      options.styleId = styleId;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [self setCustomMapStyleOptions:options];
      self.customMapStyleEnabled = YES;
    });
  });
}

- (void)setAccuracyRingEnabled:(BOOL)accuracyRingEnabled {
  _accuracyRingEnabled = accuracyRingEnabled;
  self.locationRender.showsAccuracyRing = accuracyRingEnabled;
}

- (void)setHeadingIndicatorEnabled:(BOOL)headingIndicatorEnabled {
  _headingIndicatorEnabled = headingIndicatorEnabled;
  self.locationRender.showsHeadingIndicator = headingIndicatorEnabled;
}

- (void)setAccuracyRingFillColor:(UIColor *)accuracyRingFillColor {
  _accuracyRingFillColor = accuracyRingFillColor;
  self.locationRender.fillColor = accuracyRingFillColor;
}

- (void)setAccuracyRingLineWidth:(CGFloat)accuracyRingLineWidth {
  _accuracyRingLineWidth = accuracyRingLineWidth;
  self.locationRender.lineWidth = accuracyRingLineWidth;
}

- (void)setAccuracyRingStokrColor:(UIColor *)accuracyRingStokrColor {
  _accuracyRingStokrColor = accuracyRingStokrColor;
  self.locationRender.strokeColor = accuracyRingStokrColor;
}

- (void)setPulseAnnimationEnable:(BOOL)pulseAnnimationEnable {
  _pulseAnnimationEnable = pulseAnnimationEnable;
  self.locationRender.enablePulseAnnimation = pulseAnnimationEnable;
}

- (void)setLocationDotBgColor:(UIColor *)locationDotBgColor {
  _locationDotBgColor = locationDotBgColor;
  self.locationRender.locationDotBgColor = locationDotBgColor;
}

- (void)setLocationDotFillColor:(UIColor *)locationDotFillColor {
  _locationDotFillColor = locationDotFillColor;
  self.locationRender.locationDotFillColor = locationDotFillColor;
}

- (void)setLocationImage:(NSDictionary *)locationImage {
    _locationImageData = locationImage;
    _locationImage = locationImage;
  
    __weak __typeof__(self) weakSelf = self;
    [self.imageLoader loadImage:locationImage callback:^(UIImage * _Nonnull image) {
        __strong __typeof__(self) strongSelf = weakSelf;
        strongSelf->locationIcon = image;
    }];
}

- (void)updateUserLocationRepresentation:(MAUserLocationRepresentation *)representation {
  // 调用父类方法更新用户位置表示
  [super updateUserLocationRepresentation:representation];
}

- (void)setLocationIcon:(NSDictionary *)locationI {
    __weak __typeof__(self) weakSelf = self;
    [self.imageLoader loadImage:locationI callback:^(UIImage * _Nonnull image) {
        __strong __typeof__(self) strongSelf = weakSelf;
        strongSelf->locationIcon = image;
        strongSelf.locationRender.image = image;
    }];
}

- (void)loadRender {
  self.locationRender.showsAccuracyRing = self.accuracyRingEnabled;
  self.locationRender.showsHeadingIndicator = self.headingIndicatorEnabled;
  self.locationRender.fillColor = self.accuracyRingFillColor;
  self.locationRender.lineWidth = self.accuracyRingLineWidth;
  self.locationRender.strokeColor = self.accuracyRingStokrColor;
  self.locationRender.enablePulseAnnimation = self.pulseAnnimationEnable;
  self.locationRender.locationDotBgColor = self.locationDotBgColor;
  self.locationRender.locationDotFillColor = self.locationDotFillColor;
  NSLog(@"加载图片----->2");

  if (locationIcon != nil) {
    self.locationRender.image = locationIcon;
    NSLog(@"加载图片----->3");
    if (self.locationAnnotationView != nil) {
      NSLog(@"加载图片----->4");
      self.locationAnnotationView.image = locationIcon;
    }
    [self updateUserLocationRepresentation:self.locationRender];
  } else {
    NSLog(@"加载图片----->else5");
    NSLog(@"加载图片----->else8 %@", self.locationImageData);
    if (self.locationImageData != nil) {
      NSLog(@"加载图片----->else6");
      [self.imageLoader loadImage:self.locationImageData
                         callback:^(UIImage *image) {
                          NSLog(@"加载图片----->else7");
                        }];
    } else {
      NSLog(@"加载图片----->else9 %@", self.locationImage);
      __weak __typeof__(self) weakSelf = self;
      [self.imageLoader loadImage:self.locationImage
                         callback:^(UIImage *image) {
          __strong __typeof__(self) strongSelf = weakSelf;
          NSLog(@"加载图片----->else7");
          strongSelf->locationIcon = image;
          strongSelf.locationRender.image = image;
          [strongSelf updateUserLocationRepresentation:strongSelf.locationRender];
                          
        }];
        
    }
  }
}

- (void)loadImage {
  if (self.locationImage != nil) {
    __weak __typeof__(self) weakSelf = self;
    [self.imageLoader loadImage:self.locationImage
                       callback:^( UIImage *image) {
        __strong __typeof__(self) strongSelf = weakSelf;
        strongSelf->locationIcon = image;
        strongSelf.locationRender.image = image;
    }];
  }
}

- (void)setInitialCameraPosition:(NSDictionary *)json {
  if (!self.initialized) {
    self.initialized = YES;
    [self moveCamera:json duration:0];
  }
}

- (void)moveCamera:(NSDictionary *)position duration:(NSInteger)duration {
    MAMapStatus *status = [[MAMapStatus alloc] init];
    
    status.zoomLevel = position[@"zoom"] ? [(NSNumber *)position[@"zoom"] doubleValue] : self.zoomLevel;
    status.cameraDegree = position[@"tilt"] ? [(NSNumber *)position[@"tilt"] doubleValue] : self.cameraDegree;
    status.rotationDegree = position[@"bearing"] ? [(NSNumber *)position[@"bearing"] doubleValue] : self.rotationDegree;
    
    NSDictionary *target = position[@"target"];
    if(target && target[@"latitude"] && target[@"longitude"]) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([(NSNumber *)target[@"latitude"] doubleValue], [(NSNumber *)target[@"longitude"] doubleValue]);
        status.centerCoordinate = coordinate;
    }else {
        status.centerCoordinate = self.centerCoordinate;
    }
  
    [self setMapStatus:status animated:YES duration:duration / 1000.0];
}

- (void)callWithId:(double)callerId name:(NSString *)name args:(NSDictionary *)args {
  if ([name isEqualToString:@"getLatLng"]) {
    // 实现convert方法的逻辑
      CGPoint point = CGPointMake([(NSNumber *)args[@"x"] floatValue], [(NSNumber *)args[@"y"] floatValue]);
      CLLocationCoordinate2D coordinate = [self convertPoint:point toCoordinateFromView:self];
      [self callback:callerId data:@{@"latitude": @(coordinate.latitude), @"longitude": @(coordinate.longitude)}];
  }else if ([name isEqualToString:@"reload"]) {
      NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.annotations];
      if (self.userLocation) {
          [annotations removeObject: self.userLocation];
      }
      [self removeAnnotations:annotations];
      [self addAnnotations:annotations];
  }
}

- (void)callback:(double)callerId data:(NSDictionary *)data {
  self.onCallback(@{@"id": @(callerId), @"data": data});
}

- (void)didAddSubview:(UIView *)subview {
  [super didAddSubview:subview];
  if ([subview conformsToProtocol:@protocol(Overlay)]) {
      id<Overlay> overlayView = (id<Overlay>)subview;
      MABaseOverlay *overlay = [overlayView getOverlay];
      if (overlay) {
          NSString *overlayDescription = [overlay description];
          [self.overlayMap setValue:subview forKey:overlayDescription];
          [self addOverlay:overlay];
      }
  } else if ([subview isKindOfClass:[MarkerView class]]) {
      MarkerView *marker = (MarkerView *)subview;
      NSString *annotationKey = [marker.annotation description];
    self.markerMap[annotationKey] = marker;
    [self addAnnotation:marker.annotation];
  } else if ([subview isKindOfClass:[MarkerComponentView class]]) {
    MarkerComponentView *markerView = (MarkerComponentView *)subview;
//      UIView *marker = markerView.contentView;
      NSString *annotationKey = [NSString stringWithFormat:@"%f_%f", markerView.latLng.latitude, markerView.latLng.longitude];
    self.markerMap[annotationKey] = markerView;
    [self addAnnotation:markerView.annotation];
  }
}

- (void)removeReactSubview:(UIView *)subview {
  [super removeReactSubview:subview];
  if ([subview conformsToProtocol:@protocol(Overlay)]) {
      id<Overlay> overlayView = (id<Overlay>)subview;
      MABaseOverlay *overlay = [overlayView getOverlay];
      if (overlay) {
          NSString *overlayDescription = [overlay description];
          [self.overlayMap removeObjectForKey: overlayDescription];
          [self removeOverlay:overlay];
      }
    
  } else if ([subview isKindOfClass:[MarkerView class]]) {
      MarkerView *marker = (MarkerView *)subview;
      NSString *annotationKey = [marker.annotation description];
    [self.markerMap removeObjectForKey: annotationKey];
    [self removeAnnotation:marker.annotation];
  }else if ([subview isKindOfClass:[MarkerComponentView class]]) {
      MarkerComponentView *markerView = (MarkerComponentView *)subview;
       NSString *annotationKey = [NSString stringWithFormat:@"%f_%f", markerView.latLng.latitude, markerView.latLng.longitude];
      [self.markerMap removeObjectForKey: annotationKey];
      [self removeAnnotation:markerView.annotation];
  }
}

#pragma MAMapViewDelegate

-(MAOverlayRenderer*)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if([overlay conformsToProtocol: @protocol(Overlay)]) {
        NSString *overlayDescription = [overlay description];
        UIView *view = self.overlayMap[overlayDescription];
        id<Overlay> overlayView = (id<Overlay>)view;
        if(overlayView) {
            return [overlayView getRenderer];
        }
    }
    return nil;
}

-(MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    MAPinAnnotationView *pinAnnotationView = nil;
    if([annotation isKindOfClass:MAPointAnnotation.self]) {
//        NSString* pinIndetifier = @"pinAnnotationIndetifier";
//        MAPinAnnotationView *pinAnnotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIndetifier];
//        if(!pinAnnotationView) {
//            pinAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIndetifier];
//        }
    }
    
    if ([annotation isKindOfClass:MAUserLocation.self]) {
        NSString* userLocationIdentifier = @"userLocationIdentifier";
        MAAnnotationView *userAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationIdentifier];
        if(!userAnnotationView) {
            userAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userLocationIdentifier];
        }
        
        if (!userAnnotationView.image) {
            if(locationIcon) {
                userAnnotationView.image = locationIcon;
            }else if (self.locationImageData) {
                __weak __typeof__(self) weakSelf = self;
                [self.imageLoader loadImage:self.locationImageData callback:^(UIImage * _Nonnull image) {
                    __strong __typeof__(self) strongSelf = weakSelf;
                    strongSelf->locationIcon = image;
                    strongSelf.locationRender.image = image;
                    userAnnotationView.image = image;
                }];
            }
        }
        
        self.locationAnnotationView = userAnnotationView;
        return userAnnotationView;
    }
    
    if ([annotation isKindOfClass:MAAnimatedAnnotation.self]) {
        NSString *annotationKey = [NSString stringWithFormat:@"%f_%f", annotation.coordinate.latitude, annotation.coordinate.longitude];
        UIView *contentView = self.markerMap[annotationKey];
        if([contentView isKindOfClass:MarkerComponentView.class]) {
            MarkerComponentView *markerView = (MarkerComponentView *)contentView;
            NSString* pointIndetifier = [NSString stringWithFormat:@"pointAnnotationIndetifier"];
            MAAnnotationView *pointAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:pointIndetifier];
            if(!pointAnnotationView) {
                pointAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointIndetifier];
                pointAnnotationView.canShowCallout = NO;
            }
            pointAnnotationView.annotation = annotation;
            if(!CGPointEqualToPoint(markerView.centerOffset, CGPointZero)) {
                pointAnnotationView.centerOffset = markerView.centerOffset;
            }
            pointAnnotationView.draggable = markerView.draggable;
            pointAnnotationView.zIndex = markerView.zIndex;
            
            if(markerView.contentView.subviews.count > 0) {
//                [markerView removeFromSuperview];
                markerView.contentView.userInteractionEnabled = NO;
                [pointAnnotationView addSubview:markerView.contentView];
                
//                CGSize size = markerView.contentView.bounds.size;
//                pointAnnotationView.centerOffset = CGPointMake(pointAnnotationView.centerOffset.x, pointAnnotationView.centerOffset.y - (size.height / 2));
                pointAnnotationView.bounds = markerView.contentView.bounds;
                
                [pointAnnotationView setNeedsLayout];
            }else {
                if(markerView.iconImage) {
                    pointAnnotationView.image = markerView.iconImage;

                }else if(markerView.icon) {
                    
                    [ImageLoader loadImageWithIcon:markerView.icon completion:^(UIImage * _Nullable image) {
                        markerView.iconImage = image;
                        pointAnnotationView.image = image;
                        [pointAnnotationView setNeedsLayout];
                    }];
                }
                
                [pointAnnotationView setNeedsLayout];
            }
            
            return pointAnnotationView;
            
        }else {
            return pinAnnotationView;
        }
        
    }
    
    return nil;

}
-(void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState {
    if([view.annotation isKindOfClass:MAPointAnnotation.class]) {
        NSString *annotationKey = [NSString stringWithFormat:@"%f_%f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
        UIView *contentView = self.markerMap[annotationKey];
        if([contentView isKindOfClass:MarkerComponentView.class]) {
            MarkerComponentView *markerView = (MarkerComponentView *)contentView;
            if (newState == MAAnnotationViewDragStateStarting) {
                if(markerView.onDragStart) {
                    markerView.onDragStart(nil);
                }else {
                    [markerView reciveEventName:@"onDragStart" data:@{}];
                }
                
            }
            if (newState == MAAnnotationViewDragStateDragging) {
                if(markerView.onDrag) {
                    markerView.onDrag(nil);
                }else {
                    [markerView reciveEventName:@"onDrag" data:@{}];
                }
            }
            if (newState == MAAnnotationViewDragStateEnding) {
                NSDictionary *coordinate = @{
                    @"latitude": @(view.annotation.coordinate.latitude),
                    @"longitude": @(view.annotation.coordinate.longitude)
                };
                
                if(markerView.onDragEnd) {
                    markerView.onDragEnd(coordinate);
                }else {
                    [markerView reciveEventName:@"onDragEnd" data:coordinate];
                }
            }
        }
        
    }
}

-(void)mapView:(MAMapView *)mapView didAnnotationViewTapped:(MAAnnotationView *)view {
    if([view.annotation isKindOfClass:MAPointAnnotation.class]) {
        NSString *annotationKey = [NSString stringWithFormat:@"%f_%f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
        UIView *contentView = self.markerMap[annotationKey];
        if([contentView isKindOfClass:MarkerComponentView.class]) {
            MarkerComponentView *markerView = (MarkerComponentView *)contentView;
            if(markerView.onPress) {
                markerView.onPress(@{});
            }else {
                [markerView reciveEventName:@"onPress" data:@{}];
            }
        }
        
    }
}

-(void)mapInitComplete:(MAMapView *)mapView {
    self.onLoad(nil);
}
-(void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    self.onPress(@{
        @"latitude": @(coordinate.latitude),
        @"longitude": @(coordinate.longitude)
    });
}

-(void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois {
    if(pois.count > 0 && [pois[0] isKindOfClass:[MATouchPoi class]]) {
        MATouchPoi *poi = pois[0];
        self.onPressPoi(@{
            @"name": poi.name,
            @"id": poi.uid,
            @"position": @{
                @"latitude": @(poi.coordinate.latitude),
                @"longitude": @(poi.coordinate.longitude)
            }});
    }
}

-(void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    self.onLongPress(@{
        @"latitude": @(coordinate.latitude),
        @"longitude": @(coordinate.longitude)
    });
}

-(void)mapViewRegionChanged:(MAMapView *)mapView {
    self.onCameraMove(self.cameraEvent);
}

-(void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.onCameraMove(self.cameraEvent);
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (!updatingLocation) {
        MAAnnotationView *userView = [mapView viewForAnnotation: userLocation];
        CLHeading *userHeading = userLocation.heading;
        if (userHeading && userView) {
            [userView rotateWithHeading:userHeading];

        }
    }
}

@end




@implementation MAAnnotationView (Rotation)

- (void)rotateWithHeading:(CLHeading *)heading {
  // 将设备的方向角度换算成弧度
  CGFloat headings = M_PI * heading.magneticHeading / 180.0;
  // 创建不断旋转CALayer的transform属性的动画
  CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
  // 动画起始值
  CATransform3D formValue = self.layer.transform;
  rotateAnimation.fromValue = [NSValue valueWithCATransform3D:formValue];
  // 绕Z轴旋转heading弧度的变换矩阵
  CATransform3D toValue = CATransform3DMakeRotation(headings, 0, 0, 1);
  // 设置动画结束值
  rotateAnimation.toValue = [NSValue valueWithCATransform3D:toValue];
  rotateAnimation.duration = 0.35;
  rotateAnimation.removedOnCompletion = YES;
  // 设置动画结束后layer的变换矩阵
  self.layer.transform = toValue;
  // 添加动画
  [self.layer addAnimation:rotateAnimation forKey:nil];
}

@end
