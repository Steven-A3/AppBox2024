//
//  NSManagedObject+Clone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Clone)

- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context;
@end
