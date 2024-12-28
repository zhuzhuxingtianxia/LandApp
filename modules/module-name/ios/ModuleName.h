
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNModuleNameSpec.h"

@interface ModuleName : NSObject <NativeModuleNameSpec>
#else
#import <React/RCTBridgeModule.h>

@interface ModuleName : NSObject <RCTBridgeModule>
#endif

@end
