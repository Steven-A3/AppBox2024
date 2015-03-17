//
//  CDECloudKitFileSystem.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 9/22/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import <Ensembles/Ensembles.h>

extern NSString * const CDECloudKitRecordZoneName;

@interface CDECloudKitFileSystem : NSObject <CDECloudFileSystem>

@property (nonatomic, readonly) NSString *ubiquityContainerIdentifier;
@property (nonatomic, readonly) BOOL usePublicDatabase;
@property (nonatomic, readonly) NSString *rootDirectory;

- (instancetype)initWithUbiquityContainerIdentifier:(NSString *)ubiquity rootDirectory:(NSString *)rootPath usePublicDatabase:(BOOL)usePublic;

- (void)subscribeForPushNotificationsWithCompletion:(CDECompletionBlock)completion;

@end
