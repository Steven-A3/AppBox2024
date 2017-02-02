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

typedef NS_ENUM(NSUInteger, CDECloudKitSchemaVersion) {
    CDECloudKitSchemaVersion1 = 1, /// The original schema
    CDECloudKitSchemaVersion2 = 2  /// Schema with no separate CDEDataFile record type
};

/// The CloudKit database that is being used.
typedef NS_ENUM(NSInteger, CDEDatabaseScope) {
    CDEDatabaseScopePublic = 1,
    CDEDatabaseScopePrivate,
    CDEDatabaseScopeShared,
};

@class CDECloudKitFileSystem;

@protocol CDECloudKitFileSystemDelegate <NSObject>

/**
 Called when a `CKShare` has become available on the owner's device, either because
 it has been fetched from the cloud, or it has been created and saved to the cloud.
 This may be a good moment to invite other users to join the share. 
 This method is not called on the devices of non-owners.
 */
- (void)cloudKitFileSystemShareIsAvailable:(CDECloudKitFileSystem *)fileSystem;

@end


@interface CDECloudKitFileSystem : NSObject <CDECloudFileSystem>

@property (nonatomic, readwrite, weak) id <CDECloudKitFileSystemDelegate> delegate;
@property (nonatomic, readonly) NSString *ubiquityContainerIdentifier;
@property (nonatomic, readonly) CDEDatabaseScope databaseScope;
@property (nonatomic, readonly) CKContainer *container;
@property (nonatomic, readonly) CKDatabase *database;
@property (nonatomic, readonly) CKRecordZoneID *recordZoneID; /// nil for the default zone
@property (nonatomic, readonly) NSString *rootDirectory;
@property (nonatomic, readonly) NSString *recordZoneName;
@property (nonatomic, readonly) NSString *sharingIdentifier;
@property (nonatomic, readonly) CKShare *share;
@property (nonatomic, readonly) NSString *shareOwnerName;
@property (nonatomic, readonly) CDECloudKitSchemaVersion schemaVersion;

/**
 Initialize CloudKit to use the default zone with the private or public database.
 Code that uses this initializer should not be changed to use other initializers.
 Choose an appropriate schema for what you already have in the app store. If you
 haven't shipped an app yet, pick the newest schema. Changing the schema causes
 your app to begin syncing from the beginning, reuploading all data.
 This initializer is not recommended for the private database.
 */
- (instancetype)initWithUbiquityContainerIdentifier:(NSString *)ubiquity rootDirectory:(NSString *)rootPath usePublicDatabase:(BOOL)usePublic schemaVersion:(CDECloudKitSchemaVersion)schema;

/**
 Initialize CloudKit to use a custom zone with the private database.
 This makes transactions atomic, which may lead to more stability and gives better
 performance. Code that uses this initializer should not be changed to use other initializers.
 Choose an appropriate schema for what you already have in the app store. If you
 haven't shipped an app yet, pick the newest schema. Changing the schema causes
 your app to begin syncing from the beginning, reuploading all data.
 */
- (instancetype)initWithPrivateDatabaseForUbiquityContainerIdentifier:(NSString *)ubiquity schemaVersion:(CDECloudKitSchemaVersion)schema;

/** 
 Initializes CloudKit to use a `CKShare` and a custom zone for sharing a store
 between multiple users. Each persistent store can be shared between one group of
 iCloud users; to support multiple groups of users, you need multiple persistent stores.
 The sharing identifier is used to construct a record id for the share, as well
 as the custom zone name.
 
 Shared data has an owner. The user who initially creates the share is the owner,
 and the data resides in that user's private CloudKit database. For this user, you should pass
 `CKCurrentUserDefaultName` as the `shareOwnerName:` parameter.
 
 Other users get invited to the share using a URL, and for them the data is found in the shared CloudKit database.
 For those users, the `shareOwnerName` will correspond to the user who originally shared the content.
 This owner name needs to be stored by the app somewhere (eg `NSUserDefaults`), and passed in when creating 
 the `CDECloudKitFileSystem` instance.
 
 The first time this method is called by the owner, it will create a `CKRecordZone` and `CKShare`. 
 The delegate will be informed when the share is ready, and this may be a good moment to 
 invite other users. Apple provide UI on iOS and macOS for this purpose.
 */
- (instancetype)initWithUbiquityContainerIdentifier:(NSString *)ubiquity sharingIdentifier:(NSString *)newSharingIdentifier shareOwnerName:(NSString *)ownerName;

/**
 Subscribe for push notifications. You need to handle these in your app delegate, and trigger
 a merge when they arise (if desired).
 */
- (void)subscribeForPushNotificationsWithCompletion:(CDECompletionBlock)completion;

/**
 Accept invitation to the share for the metadata passed in. Note that this is a class method. You will usually call
 it before setting up your ensemble or cloud file system, when the app delegate receives notification that an invite
 URL has been opened by the user. Calling this method accepts the invitation, and from that point, it is possible
 to create the file system object and join the ensemble.
 */
+ (void)acceptInvitationToShareWithMetadata:(CKShareMetadata *)metadata completion:(CDECompletionBlock)completion;

@end
