//
//  A3SyncManager+mainmenu.h
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 2023/04/29.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

NS_ASSUME_NONNULL_BEGIN

@implementation A3SyncManager (mainmenu)

- (NSUInteger)maximumRecentlyUsedMenus {
    id value = [self objectForKey:A3MainMenuUserDefaultsMaxRecentlyUsed];
    return value ? [value unsignedIntegerValue] : 3;
}

@end

NS_ASSUME_NONNULL_END
