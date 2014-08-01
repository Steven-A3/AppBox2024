//
//  CDEIntegrationUpdater.h
//  Ensembles iOS
//
//  Created by Drew McCormack on 02/05/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CDEIntegrationStage.h"

@class CDEEventStore;

@interface CDEUpdateStage : CDEIntegrationStage

@property (nonatomic, readwrite, assign) BOOL updatesAttributes;
@property (nonatomic, readwrite, copy) NSArray *relationshipsToUpdate;

@end
