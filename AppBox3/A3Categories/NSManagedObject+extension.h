//
//  NSManagedObject(extension)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/1/14 10:28 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSManagedObject (extension)

- (void)repairWithError:(NSError *)error;
- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context;
- (void)nullifyAttributes;
- (void)assignOrderAsFirst;
- (void)assignOrderAsLast;
+ (NSNumber *)aggregationOperation:(NSString *)operator column:(NSString *)column predicate:(NSPredicate *)predicate;
+ (instancetype)findFirstOrderedByAttribute:(NSString *)attribute ascending:(BOOL)ascending;
+ (NSArray *)findAllSortedBy:(NSString *)attribute ascending:(BOOL)ascending;
+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate;
+ (instancetype)findFirst;
+ (instancetype)findFirstByAttribute:(NSString *)attribute withValue:(NSString *)value;
+ (instancetype)findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending;
+ (instancetype)findFirstWithPredicate:(NSPredicate *)searchTerm;
+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue;
+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending;
+ (NSUInteger)countOfEntities;
+ (NSUInteger)countOfEntitiesWithPredicate:(NSPredicate *)predicate;
+ (void)truncateAll;
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate;
+ (NSFetchedResultsController *)fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate;

@end
