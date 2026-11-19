//
//  CynoptaLaunchState.h
//  CynoptaKit
//
//  Created by Max O on 18/11/2026.
//  Copyright © 2026 Anagog Ltd. All rights reserved.
//

#ifndef CynoptaKit_CynoptaLaunchState_h
#define CynoptaKit_CynoptaLaunchState_h

#include <stdbool.h>

// Whether UIKit has posted UIApplicationDidFinishLaunchingNotification, which it does once
// application(_:didFinishLaunchingWithOptions:) has returned. BGTaskScheduler throws when a task is registered after
// that, and a Flutter plugin can start the SDK later (Flutter's scene-based template registers plugins when the scene
// connects). Recorded from the moment CynoptaKit loads, which a Swift static can't do. Not API.
bool CynoptaApplicationDidFinishLaunching(void);

#endif
