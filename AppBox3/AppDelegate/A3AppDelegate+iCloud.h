//
//  A3AppDelegate+iCloud.h
//  AppBox3
//
//  Created by A3 on 12/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"


extern NSString *const A3NotificationCoreDataReady;

@interface A3AppDelegate (iCloud) <UbiquityStoreManagerDelegate>

- (void)setupCloud;
- (void)setCloudEnabled:(BOOL)enable;

- (void)resetCoreDataStack;
@end
