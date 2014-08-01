//
//  CDEEventFileSetTests.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 22/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDEEventFileSet.h"

@interface CDEEventFileSetTests : XCTestCase

@end

@implementation CDEEventFileSetTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitializingWithInvalidFilename
{
    XCTAssertNil([[CDEEventFileSet alloc] initWithFilename:@"Wrong" isBaseline:NO], @"Should give nil object");
}

- (void)testInitializingWithLegacyBaseline
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK.cdeevent" isBaseline:YES];
    XCTAssertTrue(set.isBaseline, @"Should be baseline");
    XCTAssertEqualObjects(@"JHK-HKJH-LHK", set.uniqueIdentifier, @"Wrong unique id");
    XCTAssertEqual(set.globalCount, (NSUInteger)345, @"Wrong global count");
    XCTAssertNil(set.persistentStoreIdentifier, @"Should have no persistent store id");
    XCTAssertEqual(set.totalNumberOfParts, (NSUInteger)1, @"Wrong number of parts");
}

- (void)testInitializingWithNewBaseline
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ.cdeevent" isBaseline:YES];
    XCTAssertTrue(set.isBaseline, @"Should be baseline");
    XCTAssertEqual(set.globalCount, (NSUInteger)345, @"Wrong global count");
    XCTAssertEqualObjects(@"JHK-HKJH-LHK", set.uniqueIdentifier, @"Wrong unique id");
    XCTAssertNil(set.persistentStoreIdentifier, @"Should have no persistent store id");
    XCTAssertEqualObjects(set.persistentStorePrefix, @"JFHDJHBJ", @"Should have persistent store id prefix");
    XCTAssertEqual(set.totalNumberOfParts, (NSUInteger)1, @"Wrong number of parts");
}

- (void)testInitializingWithStandardEvent
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHKTKJKJ-HKJH-LHK_67.cdeevent" isBaseline:NO];
    XCTAssertFalse(set.isBaseline, @"Should not be baseline");
    XCTAssertEqual(set.globalCount, (NSUInteger)345, @"Wrong global count");
    XCTAssertEqual(set.revisionNumber, (NSUInteger)67, @"Wrong rev number");
    XCTAssertEqualObjects(@"JHKTKJKJ-HKJH-LHK", set.persistentStoreIdentifier, @"Wrong persistent store id");
    XCTAssertEqualObjects(set.persistentStorePrefix, @"JHKTKJKJ", @"Should have persistent store id prefix");
    XCTAssertEqual(set.totalNumberOfParts, (NSUInteger)1, @"Wrong number of parts");
}

- (void)testMultipartBaseline
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    XCTAssertTrue(set.isBaseline, @"Should be baseline");
    XCTAssertEqual(set.globalCount, (NSUInteger)345, @"Wrong global count");
    XCTAssertEqualObjects(@"JHK-HKJH-LHK", set.uniqueIdentifier, @"Wrong unique id");
    XCTAssertNil(set.persistentStoreIdentifier, @"Should have no persistent store id");
    XCTAssertEqualObjects(set.persistentStorePrefix, @"JFHDJHBJ", @"Should have persistent store id prefix");
    XCTAssertEqual(set.totalNumberOfParts, (NSUInteger)23, @"Wrong number of parts");
    XCTAssertEqual(set.partIndexSet.count, (NSUInteger)1, @"Should be a single part in set");
}

- (void)testMultipartStandardEvent
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK-JFHDJHBJ_7_3of23.cdeevent" isBaseline:NO];
    XCTAssertFalse(set.isBaseline, @"Should not be baseline");
    XCTAssertEqual(set.globalCount, (NSUInteger)345, @"Wrong global count");
    XCTAssertEqual(set.revisionNumber, (NSUInteger)7, @"Wrong rev number");
    XCTAssertEqualObjects(@"JHK-HKJH-LHK-JFHDJHBJ", set.persistentStoreIdentifier, @"Wrong persistent store id");
    XCTAssertEqualObjects(set.persistentStorePrefix, @"JHK-HKJH", @"Should have persistent store id prefix");
    XCTAssertEqual(set.totalNumberOfParts, (NSUInteger)23, @"Wrong number of parts");
    XCTAssertEqual(set.partIndexSet.count, (NSUInteger)1, @"Should be a single part in set");
}

- (void)testAddingAPartToBaseline
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    [set addPartIndexForFile:@"345_JHK-HKJH-LHK_JFHDJHBJ_4of23.cdeevent"];
    XCTAssertEqual(set.partIndexSet.count, (NSUInteger)2, @"Should be two parts in set");
}

- (void)testAddingAPartToStandardEvent
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK-JFHDJHBJ_7_3of23.cdeevent" isBaseline:NO];
    [set addPartIndexForFile:@"345_JHK-HKJH-LHK-JFHDJHBJ_7_4of23.cdeevent"];
    XCTAssertEqual(set.partIndexSet.count, (NSUInteger)2, @"Should be two parts in set");
}


- (void)testAddingAPartTwice
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    [set addPartIndexForFile:@"345_JHK-HKJH-LHK_JFHDJHBJ_4of23.cdeevent"];
    [set addPartIndexForFile:@"345_JHK-HKJH-LHK_JFHDJHBJ_4of23.cdeevent"];
    XCTAssertEqual(set.partIndexSet.count, (NSUInteger)2, @"Should be two parts in set");
}

- (void)testPartMembership
{
    CDEEventFileSet *set = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    [set addPartIndexForFile:@"345_JHK-HKJH-LHK_JFHDJHBJ_12of23.cdeevent"];
    XCTAssertTrue([set containsFile:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent"], @"Should be member");
    XCTAssertTrue([set containsFile:@"345_JHK-HKJH-LHK_JFHDJHBJ_12of23.cdeevent"], @"Should be member");
    XCTAssertTrue([set containsFile:@"345_JHK-HKJH-LHK_JFHDJHBJ_1of23.cdeevent"], @"Should be member");
    XCTAssertFalse([set containsFile:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of24.cdeevent"], @"Should not be member. Total count wrong.");
}

- (void)testCreatingEventFileSetsForManyFiles
{
    NSSet *filenames = [NSSet setWithObjects:
        @"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent", // Baseline 1
        @"345_JHK-HKJH-LHK_JFHDJHBJ_1of23.cdeevent", // Baseline 1
        @"345_AHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent", // Baseline 2
        @"345_AHK-HKJH-LHK_JFHDJHBJ_1of23.cdeevent", // Baseline 2
        nil];
    NSSet *sets = [CDEEventFileSet eventFileSetsForFilenames:filenames containingBaselines:YES];
    XCTAssertEqual(sets.count, (NSUInteger)2, @"Wrong number of multipart event files");
}

- (void)testEventFileRepresentsSameEventFileAsItself
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    XCTAssertTrue([set1 representsSameEventAsEventFileSet:set2], @"Should represent same file");
}

- (void)testDifferentPartsOfEventFileRepresentsSameEventFile
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_20of23.cdeevent" isBaseline:YES];
    XCTAssertTrue([set1 representsSameEventAsEventFileSet:set2], @"Should represent same file");
}

- (void)testDifferingBaselineSettingOfEventFileDoesNotRepresentsSameEventFile
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"345_JFHDJHBJ_3of23.cdeevent" isBaseline:NO];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_20of23.cdeevent" isBaseline:YES];
    XCTAssertFalse([set1 representsSameEventAsEventFileSet:set2], @"Should not represent same file");
}

- (void)testLegacyBaselineMatchesMultipartBaseline
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK.cdeevent" isBaseline:YES];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_20of23.cdeevent" isBaseline:YES];
    XCTAssertTrue([set1 representsSameEventAsEventFileSet:set2], @"Should represent same file");
}

- (void)testSinglePartFileSetMatchesMultipartFileSet
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_1.cdeevent" isBaseline:NO];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_1_1of2.cdeevent" isBaseline:NO];
    XCTAssertTrue([set1 representsSameEventAsEventFileSet:set2], @"Should represent same file");
}

- (void)testDifferingRevisionNumberDoNoRepresentSameFileSet
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_2_2of2.cdeevent" isBaseline:NO];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_1_1of2.cdeevent" isBaseline:NO];
    XCTAssertFalse([set1 representsSameEventAsEventFileSet:set2], @"Should not represent same file");
}

- (void)testDifferingGlobalCountInBaselinesDoNotRepresentSameFileSet
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"346_JHK-HKJH-LHK_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_20of23.cdeevent" isBaseline:YES];
    XCTAssertFalse([set1 representsSameEventAsEventFileSet:set2], @"Should not represent same file");
}

- (void)testDifferingStorePrefixInBaselinesDoNotRepresentSameFileSet
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJKKK_3of23.cdeevent" isBaseline:YES];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_20of23.cdeevent" isBaseline:YES];
    XCTAssertFalse([set1 representsSameEventAsEventFileSet:set2], @"Should not represent same file");
}

- (void)testDifferingUniqueIdsInBaselinesDoNotRepresentSameFileSet
{
    CDEEventFileSet *set1, *set2;
    set1 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LLL_JFHDJHBJ_3of23.cdeevent" isBaseline:YES];
    set2 = [[CDEEventFileSet alloc] initWithFilename:@"345_JHK-HKJH-LHK_JFHDJHBJ_20of23.cdeevent" isBaseline:YES];
    XCTAssertFalse([set1 representsSameEventAsEventFileSet:set2], @"Should not represent same file");
}

@end
