//
//  A3DataMigrationManager.h
//  AppBox3
//
//  Created by A3 on 5/26/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

@class A3DataMigrationManager;

@protocol A3DataMigrationManagerDelegate <NSObject>
- (void)migrationManager:(A3DataMigrationManager *)manager didFinishMigration:(BOOL)success;
@end

@interface A3DataMigrationManager : NSObject

@property (nonatomic, weak) id<A3DataMigrationManagerDelegate> delegate;
@property (nonatomic, copy) NSString *migrationDirectory;
@property (nonatomic, assign) BOOL canCancelInEncryptionKeyView;
@property (nonatomic, weak) UIViewController *hostingViewController;

- (instancetype)init;
- (void)migrateV1DataWithPassword:(NSString *)password;
- (BOOL)walletDataFileExists;
- (NSDictionary *)walletDataWithPassword:(NSString *)password;
- (void)askWalletPassword;

@end
