#import "ZkVpnPlugin.h"
#if __has_include(<zk_vpn/zk_vpn-Swift.h>)
#import <zk_vpn/zk_vpn-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "zk_vpn-Swift.h"
#endif

@implementation ZkVpnPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZkVpnPlugin registerWithRegistrar:registrar];
}
@end
