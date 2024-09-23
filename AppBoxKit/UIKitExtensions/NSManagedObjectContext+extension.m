//
//  NSManagedObject(extension)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/1/14 10:28 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "NSManagedObjectContext+extension.h"
#import "common.h"

@implementation NSManagedObjectContext (extension)

- (void)saveIfNeeded {
    if ([self hasChanges]) {
        NSError *saveError = nil;
        [self save:&saveError];
        if (saveError) {
            FNLOG(@"%@", saveError);
        }
    }
}

@end
