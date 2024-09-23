//
//  NSManagedObjectContext+extension.h
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 2023/03/15.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (extension)

- (void)saveIfNeeded;

@end
