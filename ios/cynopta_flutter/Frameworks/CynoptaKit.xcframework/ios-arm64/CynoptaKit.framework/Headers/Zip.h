//
//  Zip.h
//  CynoptaKit
//
//  Created by Mark Berner on 27/06/2022.
//  Copyright © 2022 Anagog Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Zip)
@interface CynoptaZip : NSObject

+ (BOOL)createZipFileAtPath:(NSString *)path
    withContentsOfDirectory:(NSString *)directoryPath
        keepParentDirectory:(BOOL)keepParentDirectory
           compressionLevel:(int)compressionLevel
                   password:(nullable NSString *)password;
                   
+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
                  error:(NSError **)error;

+ (BOOL)unzipFileAtPath:(NSString *)path
          toDestination:(NSString *)destination
               password:(nullable NSString *)password
                  error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
