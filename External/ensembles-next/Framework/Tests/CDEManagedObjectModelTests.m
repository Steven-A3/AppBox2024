//
//  CDEManagedObjectModelTests.m
//  Ensembles
//
//  Created by Drew McCormack on 08/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSManagedObjectModel+CDEAdditions.h"

@interface CDEManagedObjectModelTests : XCTestCase

@end

@implementation CDEManagedObjectModelTests {
    NSManagedObjectModel *model;
}

- (void)setUp
{
    [super setUp];
    
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@"CDEStoreModificationEventTestsModel" withExtension:@"momd"];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testModelCreated
{
    XCTAssertNotNil(model, @"Model not created");
}

- (void)testModelHash
{
    NSString *hash = [model cde_modelHash];
    NSString *childHash = model.entityVersionHashesByName[@"Child"];
    NSString *parentHash = model.entityVersionHashesByName[@"Parent"];
    NSString *batchGrandParent = model.entityVersionHashesByName[@"BatchGrandParent"];
    NSString *batchParentHash = model.entityVersionHashesByName[@"BatchParent"];
    NSString *batchChildHash = model.entityVersionHashesByName[@"BatchChild"];
    NSString *derivedParentHash = model.entityVersionHashesByName[@"DerivedParent"];
    NSString *derivedChildHash = model.entityVersionHashesByName[@"DerivedChild"];
    NSString *expectedHash = [NSString stringWithFormat:@"BatchChild_%@__BatchGrandParent_%@__BatchParent_%@__Child_%@__DerivedChild_%@__DerivedParent_%@__Parent_%@", batchChildHash, batchGrandParent, batchParentHash, childHash, derivedChildHash, derivedParentHash, parentHash];
    XCTAssertEqualObjects(hash, expectedHash, @"Hash wrong");
}

- (void)testEntityHashesPropertyList
{
    NSString *propertyList = [model cde_entityHashesPropertyList];
    NSDictionary *dictionary = [NSManagedObjectModel cde_entityHashesByNameFromPropertyList:propertyList];
    XCTAssertNotNil(dictionary, @"Property list was nil");
}

- (void)testEntityHashesPropertyListWithNilString
{
    NSDictionary *dictionary = [NSManagedObjectModel cde_entityHashesByNameFromPropertyList:nil];
    XCTAssertNil(dictionary, @"Property list was not nil");
}

@end
