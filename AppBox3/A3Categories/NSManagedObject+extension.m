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

@end
