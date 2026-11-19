//
//  TelephonySafeBridge.h
//  CynoptaKit
//
//  Created by Benny on 28/08/2025.
//  Copyright © 2025 Anagog Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TelephonySafeBridge)
@interface CynoptaTelephonySafeBridge : NSObject

/// Returns a safe snapshot of dataServiceIdentifier and radioTech dictionary.
/// If CoreTelephony misbehaves, an NSException is returned via `exceptionPtr`.
+ (NSDictionary *)safeSnapshot:(CTTelephonyNetworkInfo *)info
                     exception:(NSException * __autoreleasing _Nullable * _Nullable)exceptionPtr;

@end

NS_ASSUME_NONNULL_END

