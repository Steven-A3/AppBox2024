//
//  NSManagedObject+Clone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSManagedObject+Clone.h"

@implementation NSManagedObject (Clone)

- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context {
	NSString *entityName = [[self entity] name];

	//create new object in data store
	NSManagedObject *cloned = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];

	//loop through all attributes and assign then to the clone
	NSDictionary *attributes = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] attributesByName];

	for (NSString *attr in attributes) {
		[cloned setValue:[self valueForKey:attr] forKey:attr];
	}

	return cloned;
}

@end
