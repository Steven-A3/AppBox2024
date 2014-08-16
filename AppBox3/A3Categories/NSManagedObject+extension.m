//
//  NSManagedObject(extension)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/1/14 10:28 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "NSManagedObject+extension.h"
#import "NSString+conversion.h"
#import "NSMutableArray+A3Sort.h"
#import "A3UserDefaultsKeys.h"

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
	NSDictionary *attributes = [[NSEntityDescription entityForName:[[self entity] name] inManagedObjectContext:(context ? context : self.managedObjectContext)] attributesByName];
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

- (void)assignOrderAsFirstInContext:(NSManagedObjectContext *)context {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", ID_KEY, [self valueForKey:ID_KEY]];
	NSManagedObject *obj = [[self class] MR_findFirstWithPredicate:predicate sortedBy:A3CommonPropertyOrder ascending:YES inContext:context];
	NSString *minOrder = [obj valueForKey:A3CommonPropertyOrder];
	NSInteger minOrderValue = [minOrder integerValue];
	if (minOrderValue > 1) {
		[self setValue:[NSString orderStringWithOrder:minOrderValue / 2] forKey:A3CommonPropertyOrder];
	} else {
		NSArray *allItems = [[self class] MR_findAllInContext:context];
		NSInteger newOrder = 1000000;
		for (NSManagedObject *object in allItems) {
			[object setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];
			newOrder += 1000000;
		}
	}
}

- (void)assignOrderAsLastInContext:(NSManagedObjectContext *)context {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", ID_KEY, [self valueForKey:ID_KEY]];
	NSManagedObject *obj = [[self class] MR_findFirstWithPredicate:predicate sortedBy:A3CommonPropertyOrder ascending:NO inContext:context];
	NSString *maxOrder = [obj valueForKey:A3CommonPropertyOrder];
	NSInteger maxOrderValue = [maxOrder integerValue];
	[self setValue:[NSString orderStringWithOrder:maxOrderValue + 1000000] forKey:A3CommonPropertyOrder];
}

@end
