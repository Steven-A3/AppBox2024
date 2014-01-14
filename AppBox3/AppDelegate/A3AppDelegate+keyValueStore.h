//
//  A3AppDelegate+keyValueStore.h
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"

@interface A3AppDelegate (keyValueStore)

- (void)keyValueStoreDidChangeExternally:(NSNotification *)notification;
@end
