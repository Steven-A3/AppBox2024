//
//  NSManagedObject(extension)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/1/14 10:28 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "NSManagedObjectContext+extension.h"

@implementation NSManagedObjectContext (extension)

- (void)saveContext {
    if ([self hasChanges]) {
        NSError *saveError = nil;
        [self save:&saveError];
        if (saveError) {
            FNLOG(@"%@", saveError);
        }
    }
}

@end
