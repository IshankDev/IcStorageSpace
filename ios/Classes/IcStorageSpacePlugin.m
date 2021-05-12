#import "IcStorageSpacePlugin.h"
#if __has_include(<ic_storage_space/ic_storage_space-Swift.h>)
#import <ic_storage_space/ic_storage_space-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ic_storage_space-Swift.h"
#endif

@implementation IcStorageSpacePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIcStorageSpacePlugin registerWithRegistrar:registrar];
}
@end
