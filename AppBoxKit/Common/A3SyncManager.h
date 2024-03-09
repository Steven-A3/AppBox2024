//
//  A3SyncManager.h
//  AppBox3
//
//  Created by A3 on 7/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const A3SyncManagerCloudEnabled;
extern NSString *const A3SyncDeviceSyncStartInfo;
extern NSString *const A3NotificationCloudCoreDataStoreDidImport;
extern NSString *const A3NotificationCloudKeyValueStoreDidImport;
extern NSString *const A3DaysCounterImageDirectory;
extern NSString *const A3DaysCounterImageThumbnailDirectory;
extern NSString *const A3WalletImageDirectory;
extern NSString *const A3WalletVideoDirectory;
extern NSString *const A3WalletImageThumbnailDirectory;
extern NSString *const A3WalletVideoThumbnailDirectory;

extern NSString *const A3AppName_DateCalculator;
extern NSString *const A3AppName_LoanCalculator;
extern NSString *const A3AppName_SalesCalculator;
extern NSString *const A3AppName_TipCalculator;
extern NSString *const A3AppName_UnitPrice;
extern NSString *const A3AppName_Calculator;
extern NSString *const A3AppName_PercentCalculator;
extern NSString *const A3AppName_CurrencyConverter;
extern NSString *const A3AppName_LunarConverter;
extern NSString *const A3AppName_Translator;
extern NSString *const A3AppName_UnitConverter;
extern NSString *const A3AppName_DaysCounter;
extern NSString *const A3AppName_LadiesCalendar;
extern NSString *const A3AppName_Wallet;
extern NSString *const A3AppName_ExpenseList;
extern NSString *const A3AppName_Holidays;
extern NSString *const A3AppName_Clock;
extern NSString *const A3AppName_BatteryStatus;
extern NSString *const A3AppName_Mirror;
extern NSString *const A3AppName_Magnifier;
extern NSString *const A3AppName_Flashlight;
extern NSString *const A3AppName_Random;
extern NSString *const A3AppName_Ruler;
extern NSString *const A3AppName_Level;
extern NSString *const A3AppName_QRCode;
extern NSString *const A3AppName_Pedometer;
extern NSString *const A3AppName_Abbreviation;
extern NSString *const A3AppName_Kaomoji;

extern NSString *const A3AppName_Settings;
extern NSString *const A3AppName_About;
extern NSString *const A3AppName_RemoveAds;
extern NSString *const A3AppName_RestorePurchase;
extern NSString *const A3AppName_None;

extern NSString *const kA3AdsUserDidSelectPersonalizedAds;

@class CDEPersistentStoreEnsemble, CDEICloudFileSystem;

@protocol A3AppUIContextProtocol <NSObject>

- (UINavigationController *)navigationController;

@end

typedef void (^CDECompletionBlock)(NSError * _Nullable error);

@interface A3SyncManager : NSObject

@property (nonatomic, readonly, strong) CDEPersistentStoreEnsemble *ensemble;
@property (nonatomic, strong) CDEICloudFileSystem *cloudFileSystem;
@property (nonatomic, copy) NSString *storePath;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (strong, nonatomic) NSPersistentContainer *persistentContainer;
@property (nonatomic, weak) id<A3AppUIContextProtocol>appUIContext;

+ (instancetype)sharedSyncManager;

- (BOOL)canSyncStart;

- (BOOL)isCloudAvailable;
- (void)setupEnsemble;
- (void)enableCloudSync;
- (void)disableCloudSync;
- (BOOL)isCloudEnabled;
- (void)synchronizeWithCompletion:(nullable CDECompletionBlock)completion;

- (void)uploadMediaFilesToCloud;
- (void)downloadMediaFilesFromCloud;

- (void)loadPersistentContainerInBundle:(NSBundle *)bundle withCompletion:(void (^)(NSError *))completion;
- (void)unloadPersistentContainer;

@end

NS_ASSUME_NONNULL_END
