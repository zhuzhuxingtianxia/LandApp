#import "BVLinearGradientLayer.h"

#import <UIKit/UIKit.h>

@implementation BVLinearGradientLayer

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.needsDisplayOnBoundsChange = YES;
        self.masksToBounds = YES;
        _startPoint = CGPointMake(0.5, 0.0);
        _endPoint = CGPointMake(0.5, 1.0);
        _angleCenter = CGPointMake(0.5, 0.5);
        _angle = 45.0;
    }

    return self;
}

- (void)setColors:(NSArray<id> *)colors
{
    _colors = colors;
    [self setNeedsDisplay];
}

- (void)setLocations:(NSArray<NSNumber *> *)locations
{
    _locations = locations;
    [self setNeedsDisplay];
}

- (void)setStartPoint:(CGPoint)startPoint
{
    _startPoint = startPoint;
    [self setNeedsDisplay];
}

- (void)setEndPoint:(CGPoint)endPoint
{
    _endPoint = endPoint;
    [self setNeedsDisplay];
}

- (void)display {
    [super display];

    // short circuit when height or width are 0. Fixes CGContext errors throwing
    if (self.bounds.size.height == 0 || self.bounds.size.width == 0) {
      return;
    }

    BOOL hasAlpha = NO;

    for (NSInteger i = 0; i < self.colors.count; i++) {
        hasAlpha = hasAlpha || CGColorGetAlpha(self.colors[i].CGColor) < 1.0;
    }

    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRendererFormat *format;
        if (@available(iOS 11.0, *)) {
            format = [UIGraphicsImageRendererFormat preferredFormat];
        } else {
            format = [UIGraphicsImageRendererFormat defaultFormat];
        }
        format.opaque = !hasAlpha;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size format:format];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull ref) {
            [self drawInContext:ref.CGContext];
        }];

        self.contents = (__bridge id _Nullable)(image.CGImage);
        self.contentsScale = image.scale;
    } else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, !hasAlpha, 0.0);
        CGContextRef ref = UIGraphicsGetCurrentContext();
        [self drawInContext:ref];

        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        self.contents = (__bridge id _Nullable)(image.CGImage);
        self.contentsScale = image.scale;

        UIGraphicsEndImageContext();
    }
}
    
- (void)setUseAngle:(BOOL)useAngle
{
    _useAngle = useAngle;
    [self setNeedsDisplay];
}

- (void)setAngleCenter:(CGPoint)angleCenter
{
    _angleCenter = angleCenter;
    [self setNeedsDisplay];
}

- (void)setAngle:(CGFloat)angle
{
    _angle = angle;
    [self setNeedsDisplay];
}

- (CGSize)calculateGradientLocationWithAngle:(CGFloat)angle
{
    CGFloat angleRad = (angle - 90) * (M_PI / 180);
    CGFloat length = sqrt(2);
    
    return CGSizeMake(cos(angleRad) * length, sin(angleRad) * length);
}
    
- (void)drawInContext:(CGContextRef)ctx
{
    [super drawInContext:ctx];

    CGContextSaveGState(ctx);

    CGSize size = self.bounds.size;
    if (!self.colors || self.colors.count == 0 || size.width == 0.0 || size.height == 0.0)
        return;


    CGFloat *locations = nil;

    locations = malloc(sizeof(CGFloat) * self.colors.count);

    for (NSInteger i = 0; i < self.colors.count; i++)
    {
        if (self.locations.count > i)
        {
            locations[i] = self.locations[i].floatValue;
        }
        else
        {
            locations[i] = (1.0 / (self.colors.count - 1)) * i;
        }
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:self.colors.count];
    for (UIColor *color in self.colors) {
        [colors addObject:(id)color.CGColor];
    }

    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);

    free(locations);

    CGPoint start = self.startPoint, end = self.endPoint;
    
    if (_useAngle)
    {
        CGSize size = [self calculateGradientLocationWithAngle:_angle];
        start.x = _angleCenter.x - size.width / 2;
        start.y = _angleCenter.y - size.height / 2;
        end.x = _angleCenter.x + size.width / 2;
        end.y = _angleCenter.y + size.height / 2;
    }
    
    CGContextDrawLinearGradient(ctx, gradient,
                                CGPointMake(start.x * size.width, start.y * size.height),
                                CGPointMake(end.x * size.width, end.y * size.height),
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    CGContextRestoreGState(ctx);
}

@end
