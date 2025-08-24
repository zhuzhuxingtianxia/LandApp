#import "MyView.h"
#import <react/renderer/components/MyViewSpec/RCTComponentViewHelpers.h>
#import <react/renderer/components/MyViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/MyViewSpec/EventEmitters.h>
#import <react/renderer/components/MyViewSpec/Props.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface MyView () <RCTMyViewViewProtocol>

@end

@implementation MyView {
    UIView * _view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const MyViewProps>();
#if RCT_NEW_ARCH_ENABLED
    // 新架构
#else
    // 旧架构
#endif
    _props = defaultProps;

    _view = [[UIView alloc] init];

    self.contentView = _view;
  }

  return self;
}

# pragma 自组件需要处理
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


- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    MyViewEventEmitter::OnWillShow result = MyViewEventEmitter::OnWillShow {
        .flag = "传递的数据"
    };
    self.eventEmitter.onWillShow(result);
}

# pragma-- Codegen 需要实现以下三个方法

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<MyViewComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<MyViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<MyViewProps const>(props);

    if (oldViewProps.color != newViewProps.color) {
        NSString * colorToConvert = [[NSString alloc] initWithUTF8String: newViewProps.color.c_str()];
        [_view setBackgroundColor:[self hexStringToColor:colorToConvert]];
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> MyViewCls(void)
{
    return MyView.class;
}

# pragma-- Event emitter convenience method
- (const MyViewEventEmitter &)eventEmitter
{
  return static_cast<const MyViewEventEmitter &>(*_eventEmitter);
}

# pragma -- Ref方法

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args {
  RCTMyViewHandleCommand(self, commandName, args);
}

# pragma RCTMyViewViewProtocol

- (void)reload:(NSString *)option {
    NSLog(@"ViewRef 调用 reload- option: %@", option);
}

- (UIColor *)hexStringToColor:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];

    unsigned hex;
    if (![stringScanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

@end
