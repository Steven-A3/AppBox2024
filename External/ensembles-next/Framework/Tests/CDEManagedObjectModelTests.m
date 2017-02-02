//
//  CDEManagedObjectModelTests.m
//  Ensembles
//
//  Created by Drew McCormack on 08/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSManagedObjectModel+CDEAdditions.h"
#import "NSData+CDEAdditions.h"

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

- (NSString *)expectedHashString
{
    NSData *childHash = model.entityVersionHashesByName[@"Child"];
    NSData *parentHash = model.entityVersionHashesByName[@"Parent"];
    NSData *batchGrandParent = model.entityVersionHashesByName[@"BatchGrandParent"];
    NSData *batchParentHash = model.entityVersionHashesByName[@"BatchParent"];
    NSData *batchChildHash = model.entityVersionHashesByName[@"BatchChild"];
    NSData *largeDataBlobHash = model.entityVersionHashesByName[@"LargeDataBlob"];
    NSData *derivedParentHash = model.entityVersionHashesByName[@"DerivedParent"];
    NSData *derivedChildHash = model.entityVersionHashesByName[@"DerivedChild"];
    NSData *aHash = model.entityVersionHashesByName[@"A"];
    NSData *bHash = model.entityVersionHashesByName[@"B"];
    NSData *cHash = model.entityVersionHashesByName[@"C"];
    NSString *expectedHash = [NSString stringWithFormat:@"A_%@__B_%@__BatchChild_%@__BatchGrandParent_%@__BatchParent_%@__C_%@__Child_%@__DerivedChild_%@__DerivedParent_%@__LargeDataBlob_%@__Parent_%@", aHash, bHash, batchChildHash, batchGrandParent, batchParentHash, cHash, childHash, derivedChildHash, derivedParentHash, largeDataBlobHash, parentHash];
    return expectedHash;
}

- (void)testModelHash
{
    NSString *hash = [model cde_modelHash];
    NSString *expectedHash = [self expectedHashString];
    XCTAssertEqualObjects(hash, expectedHash, @"Hash wrong");
}

- (void)testCompressedModelHash
{
    NSString *hash = [model cde_compressedModelHash];
    NSData *hashData = [[self expectedHashString] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *md5Hash = [NSString stringWithFormat:@"md5%@", [hashData cde_md5Checksum]];
    XCTAssertEqualObjects(hash, md5Hash, @"Hash wrong");
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
