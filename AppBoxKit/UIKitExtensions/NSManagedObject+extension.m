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
#import "A3SyncManager.h"
#import "common.h"
#import "AppBoxKit/AppBoxKit-Swift.h"
#import "AppBoxKit/AppBoxKit.h"

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
    NSManagedObject *cloned = [[[self class] alloc] initWithContext:context];
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

- (void)assignOrderAsFirst {
    NSManagedObjectContext *context = self.managedObjectContext;

    [context performBlock:^{
        @try {
            // Fetch the object with the minimum order value
            NSManagedObject *obj = [[self class] findFirstOrderedByAttribute:A3CommonPropertyOrder ascending:YES];

            NSString *minOrder = [obj valueForKey:A3CommonPropertyOrder];
            NSInteger minOrderValue = [minOrder integerValue];

            if (obj && minOrderValue > 1) {
                // Assign a new order value less than the current minimum
                NSString *orderString = [NSString orderStringWithOrder:MAX(1, minOrderValue / 2)];
#ifdef DEBUG
                NSString *name = [self valueForKey:@"name"];
                NSString *message = [NSString stringWithFormat:@"NEW ORDER: %@ / %@", name, orderString];
                LogDebug(message);
#endif
                [self setValue:orderString forKey:A3CommonPropertyOrder];
            } else {
                // If no minimum or all orders are very low, reassign all orders
                NSArray *allItems = [[self class] findAllSortedBy:A3CommonPropertyOrder ascending:YES];

                // Reassign all orders, ensuring the current object gets the first position
                NSInteger newOrder = 500000; // Assign first position to the current object
                NSString *orderString = [NSString orderStringWithOrder:newOrder];
                [self setValue:orderString forKey:A3CommonPropertyOrder];
#ifdef DEBUG
                NSString *name = [self valueForKey:@"name"];
                NSString *message = [NSString stringWithFormat:@"NEW ORDER: %@ / %@", name, orderString];
                LogDebug(message);
#endif
                newOrder += 1000000; // Start incrementing for others

                for (NSManagedObject *object in allItems) {
                    if (object != self) {
                        [object setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];
                        newOrder += 1000000;
                    }
                }
            }

            // Save the context
            NSError *saveError = nil;
            if (![context save:&saveError]) {
                NSLog(@"Error saving context: %@", saveError);
            }
        } @catch (NSException *exception) {
            NSLog(@"Exception occurred in assignOrderAsFirst: %@", exception);
        }
    }];
}

- (void)assignOrderAsLast {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [context performBlock:^{
        // Fetch the object with the maximum order value
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", ID_KEY, [self valueForKey:ID_KEY]];
        NSManagedObject *obj = [[self class] findFirstWithPredicate:predicate sortedBy:A3CommonPropertyOrder ascending:NO];
        
        NSString *maxOrder = [obj valueForKey:A3CommonPropertyOrder];
        NSInteger maxOrderValue = [maxOrder integerValue];
        
        // Safely set the new order value
        [self setValue:[NSString orderStringWithOrder:maxOrderValue + 1000000] forKey:A3CommonPropertyOrder];
        
        // Save the context if needed
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving context: %@", error);
        }
    }];
}

+ (NSNumber *)aggregationOperation:(NSString *)operator_ column:(NSString *)column predicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    __block NSNumber *result = nil;

    [context performBlockAndWait:^{
        NSExpression *expression = [NSExpression expressionForFunction:operator_
                                                             arguments:@[[NSExpression expressionForKeyPath:column]]];
        
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        expressionDescription.name = @"result";
        expressionDescription.expression = expression;

        // Dynamically determine the attribute type for proper result type
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self)
                                                             inManagedObjectContext:context];
        NSAttributeDescription *attributeDescription = [entityDescription attributesByName][column];
        if (attributeDescription) {
            expressionDescription.expressionResultType = attributeDescription.attributeType;
        } else {
            FNLOG(@"Column '%@' does not exist on entity '%@'", column, NSStringFromClass(self));
            return;
        }

        NSFetchRequest *fetchRequest = [self fetchRequest];
        if (predicate) {
            fetchRequest.predicate = predicate;
        }
        fetchRequest.propertiesToFetch = @[expressionDescription];
        fetchRequest.resultType = NSDictionaryResultType;
        fetchRequest.returnsObjectsAsFaults = NO;

        NSError *fetchError = nil;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError) {
            FNLOG(@"Error during aggregation operation: %@", fetchError);
            return;
        }
        if (results.count > 0) {
            NSDictionary *resultDictionary = results.firstObject;
            result = resultDictionary[@"result"];
        }
    }];
    
    return result;
}

+ (instancetype)findFirst {
    return [self findFirstWithPredicate:nil sortedBy:nil ascending:NO];
}

+ (instancetype)findFirstOrderedByAttribute:(NSString *)attribute ascending:(BOOL)ascending {
    return [self findFirstWithPredicate:nil sortedBy:attribute ascending:ascending];
}

+ (instancetype)findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)property ascending:(BOOL)ascending {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    __block id firstObject = nil;
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [self fetchRequest];
        if (searchTerm) {
            [fetchRequest setPredicate:searchTerm];
        }
        if (property) {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:property ascending:ascending];
            [fetchRequest setSortDescriptors:@[sortDescriptor]];
        }
        // Limit the fetch request to just one result for efficiency
        [fetchRequest setFetchLimit:1];
        
        NSError *fetchError = nil;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError) {
            FNLOG(@"%@", fetchError);
        }
        if ([results count] > 0) {
            firstObject = results.firstObject;
        }
    }];
    return firstObject;
}

+ (NSArray *)findAllSortedBy:(NSString *)attribute ascending:(BOOL)ascending {
    return [self findAllSortedBy:attribute ascending:ascending withPredicate:nil];
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [self fetchRequest];
        if (searchTerm) {
            [fetchRequest setPredicate:searchTerm];
        }
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortTerm ascending:ascending];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        NSError *fetchError = nil;
        results = [context executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError) {
            FNLOG(@"%@", fetchError);
            results = nil;
        }
    }];
    return results;
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [self fetchRequest];
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        NSError *fetchError = nil;
        results = [context executeFetchRequest:fetchRequest error:&fetchError];
        if (fetchError) {
            FNLOG(@"%@", fetchError);
            results = nil;
        }
    }];
    return results;
}

+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, searchValue];
    return [self findAllWithPredicate:predicate];
}

+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, searchValue];
    return [self findAllSortedBy:sortTerm ascending:ascending withPredicate:predicate];
}

+ (instancetype)findFirstByAttribute:(NSString *)attribute withValue:(NSString *)value {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, value];
    return [self findFirstWithPredicate:predicate];
}

+ (instancetype)findFirstWithPredicate:(NSPredicate *)searchTerm {
    return [self findFirstWithPredicate:searchTerm sortedBy:nil ascending:NO];
}

+ (NSUInteger)countOfEntities {
    return [self countOfEntitiesWithPredicate:nil];
}

+ (NSUInteger)countOfEntitiesWithPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    __block NSUInteger count = 0;
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [self fetchRequest];
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        fetchRequest.resultType = NSCountResultType;
        
        NSError *fetchError = nil;
        count = [context countForFetchRequest:fetchRequest error:&fetchError];
        if (fetchError) {
            FNLOG(@"%@", fetchError);
            count = NSNotFound; // Optional: Return a special value for errors.
        }
    }];
    return count;
}

+ (void)truncateAll {
    [self deleteAllMatchingPredicate:nil];
}

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [self fetchRequest];
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        
        // Create a batch delete request
        NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
        deleteRequest.resultType = NSBatchDeleteResultTypeObjectIDs; // Optimize result handling
        
        NSError *deleteError = nil;
        NSBatchDeleteResult *deleteResult = (NSBatchDeleteResult *)[context executeRequest:deleteRequest error:&deleteError];
        
        if (deleteError) {
            FNLOG(@"Error deleting objects: %@", deleteError);
            return;
        }
        
        // Merge changes to ensure in-memory objects reflect the deletion
        NSArray<NSManagedObjectID *> *deletedObjectIDs = deleteResult.result;
        if (deletedObjectIDs) {
            NSDictionary *changes = @{NSDeletedObjectsKey: deletedObjectIDs};
            [NSManagedObjectContext mergeChangesFromRemoteContextSave:changes intoContexts:@[context]];
        }
    }];
}

+ (NSFetchedResultsController *)fetchAllSortedBy:(NSString *)sortTerm
                                       ascending:(BOOL)ascending
                                  withPredicate:(NSPredicate *)searchTerm
                                        groupBy:(NSString *)groupingKeyPath
                                       delegate:(id<NSFetchedResultsControllerDelegate>)delegate {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    if (searchTerm) {
        [fetchRequest setPredicate:searchTerm];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortTerm ascending:ascending];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    // Ensure the context is accessed on its designated queue
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    __block NSFetchedResultsController *controller = nil;
    
    [context performBlockAndWait:^{
        controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                         managedObjectContext:context
                                                           sectionNameKeyPath:groupingKeyPath
                                                                    cacheName:nil];
        controller.delegate = delegate;

        NSError *fetchError = nil;
        if (![controller performFetch:&fetchError]) {
            FNLOG(@"Error performing fetch: %@", fetchError);
        }
    }];

    return controller;
}

@end
