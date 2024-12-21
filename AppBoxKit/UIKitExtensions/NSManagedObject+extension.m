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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", ID_KEY, [self valueForKey:ID_KEY]];
    NSManagedObject *obj = [[self class] findFirstWithPredicate:predicate sortedBy:A3CommonPropertyOrder ascending:YES];
    NSString *minOrder = [obj valueForKey:A3CommonPropertyOrder];
    NSInteger minOrderValue = [minOrder integerValue];
    if (minOrderValue > 1) {
        [self setValue:[NSString orderStringWithOrder:minOrderValue / 2] forKey:A3CommonPropertyOrder];
    } else {
        NSArray *allItems = [[self class] findAllWithPredicate:nil];
        NSInteger newOrder = 1000000;
        for (NSManagedObject *object in allItems) {
            [object setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];
            newOrder += 1000000;
        }
    }
}

- (void)assignOrderAsLast {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", ID_KEY, [self valueForKey:ID_KEY]];
    NSManagedObject *obj = [[self class] findFirstWithPredicate:predicate sortedBy:A3CommonPropertyOrder ascending:NO];
    NSString *maxOrder = [obj valueForKey:A3CommonPropertyOrder];
    NSInteger maxOrderValue = [maxOrder integerValue];
    [self setValue:[NSString orderStringWithOrder:maxOrderValue + 1000000] forKey:A3CommonPropertyOrder];
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
