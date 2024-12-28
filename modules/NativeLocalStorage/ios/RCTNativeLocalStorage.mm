//
//  RCTNativeLocalStorage.m
//  TurboTest1
//
//  Created by ZZJ on 2024/11/27.
//

#import "RCTNativeLocalStorage.h"

static NSString *const RCTNativeLocalStorageKey = @"local-storage";

@interface RCTNativeLocalStorage()
@property (strong, nonatomic) NSUserDefaults *localStorage;
@end

@implementation RCTNativeLocalStorage
RCT_EXPORT_MODULE(NativeLocalStorage)

- (id) init {
  if (self = [super init]) {
    _localStorage = [[NSUserDefaults alloc] initWithSuiteName:RCTNativeLocalStorageKey];
  }
  return self;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeLocalStorageSpecJSI>(params);
}

- (void)clear { 
  NSDictionary *keys = [self.localStorage dictionaryRepresentation];
    for (NSString *key in keys) {
      [self removeItem:key];
    }
}

- (NSString * _Nullable)getItem:(NSString *)key { 
  return [self.localStorage stringForKey:key];
}

- (void)removeItem:(NSString *)key { 
  [self.localStorage removeObjectForKey:key];
}

- (void)setItem:(NSString *)key value:(NSString *)value { 
  [self.localStorage setObject:value forKey:key];
  NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *libraryPath = [libraryPaths firstObject];
  NSString *prefsPath = [libraryPath stringByAppendingPathComponent:@"Preferences"];
  NSLog(@"UserDefaults path: %@", prefsPath);
}

@end
