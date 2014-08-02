//
//  NSManagedObject(extension)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/1/14 10:28 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "NSManagedObject+extension.h"

@implementation NSManagedObject (extension)

- (void)repairWithError:(NSError *)error {
	if  (
			error.code == NSValidationMissingMandatoryPropertyError ||
			error.code == NSManagedObjectValidationError ||
			error.code == NSValidationRelationshipLacksMinimumCountError
		)
	{
		[self.managedObjectContext deleteObject:self];
	}
}

- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context {
	NSManagedObject *cloned = [[self entity] MR_createInstanceInContext:context];
	NSDictionary *attributes = [[NSEntityDescription entityForName:[[self entity] name] inManagedObjectContext:context] attributesByName];
	for (NSString *attribute in attributes) {
		[cloned setValue:[self valueForKey:attribute] forKey:attribute];
	}
	return cloned;
}

- (void)nullifyAttributes {
	NSDictionary *attributes = [[NSEntityDescription entityForName:[[self entity] name] inManagedObjectContext:self.managedObjectContext] attributesByName];
	for (NSString *attribute in attributes) {
		[self setValue:nil forKey:attribute];
	}
}

@end
