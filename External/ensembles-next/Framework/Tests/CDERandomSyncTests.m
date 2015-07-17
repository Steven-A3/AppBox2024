//
//  CDERandomSyncTests.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 06/07/15.
//  Copyright (c) 2015 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDESyncTest.h"

@interface CDERandomSyncTests : CDESyncTest

@end

@implementation CDERandomSyncTests

- (void)testRandomSyncHistory
{
    [self leechStores];
    
    const uint8_t b[10001];
    NSData *data = [[NSData alloc] initWithBytes:b length:sizeof(b)];
    for (NSUInteger i = 0; i < 50; i++) {
        NSUInteger r1 = arc4random_uniform(5);
        BOOL randBool1 = arc4random_uniform(2);
        BOOL randBool2 = arc4random_uniform(2);
        switch (r1) {
            case 0: {
                id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
                [parent setValue:[[NSUUID UUID] UUIDString] forKey:@"name"];
                if (randBool2) [parent setValue:data forKey:@"data"];
                if (randBool1) [context1 save:NULL];
                break;
            }
            case 1: {
                id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
                [parent setValue:[[NSUUID UUID] UUIDString] forKey:@"name"];
                if (randBool2) [parent setValue:data forKey:@"data"];
                if (randBool1) [context2 save:NULL];
                break;
            }
            case 2: {
                [self mergeEnsemble:ensemble1];
                break;
            }
            case 3: {
                [self mergeEnsemble:ensemble2];
                break;
            }
            case 4: {
                NSString *dataRoot = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/data"];
                [[NSFileManager defaultManager] removeItemAtPath:dataRoot error:NULL];
                [[NSFileManager defaultManager] createDirectoryAtPath:dataRoot withIntermediateDirectories:NO attributes:nil error:NULL];
                break;
            }
        }
    }
    
    [context1 save:NULL];
    [context2 save:NULL];
    [self syncChanges];
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents1 = [context1 executeFetchRequest:fetch error:NULL];
    NSArray *parents2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents1.count, parents2.count);
}

@end
