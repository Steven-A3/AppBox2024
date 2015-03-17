//
//  CDEIntegrationDeleter.h
//  Ensembles iOS
//
//  Created by Drew McCormack on 02/05/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDEIntegrationStage.h"

@interface CDEDeleteStage : CDEIntegrationStage

+ (void)nullifyRelationshipsAndDeleteObject:(NSManagedObject *)object;

+ (void)nullifyGlobalIdentifierStoreURIsForChangesWithIDs:(NSArray *)changeIDs inEventContext:(NSManagedObjectContext *)context;

@end
