//
//  CDEIntegrationInserter.h
//  Ensembles iOS
//
//  Created by Drew McCormack on 02/05/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDEIntegrationStage.h"

@class CDEEventStore;

@interface CDEInsertStage : CDEIntegrationStage

@property (nonatomic, readonly) NSSet *insertedObjectIDs;

@end
