//
//  A3SettingsBackupRestoreViewController.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsBackupRestoreViewController.h"
#import "A3AppDelegate.h"
#import "A3SettingsDropboxSelectBackupViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"
#import "AAAZip.h"
#import "NSString+conversion.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3BackupRestoreManager.h"
#import "A3SyncManager.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "NSDate+TimeAgo.h"
#import <SafariServices/SafariServices.h>
#import "TJDropbox.h"
#import "TJDropboxAuthenticator.h"
#import "ACSimpleKeychain.h"
#import "NSDate-Utilities.h"
#import "NSFileManager+A3Addition.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

NSString *const kDropboxClientIdentifier = @"ody0cjvmnaxvob4";
NSString *const kDropboxDir = @"/AllAboutApps/AppBox Pro";

@interface A3SettingsBackupRestoreViewController ()
<A3SettingsDropboxSelectBackupDelegate, AAAZipDelegate, A3BackupRestoreManagerDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *backupInfoString;
@property (nonatomic, strong) A3BackupRestoreManager *backupRestoreManager;
@property (nonatomic, copy) NSString *downloadFilePath;
@property (nonatomic, copy) NSString *dropboxAccessToken;
@property (nonatomic, copy) NSDictionary *dropboxAccountInfo;
@property (nonatomic, copy) NSArray *dropboxFolderList;
@property (nonatomic, assign) BOOL restoreInProgress;

@end

@implementation A3SettingsBackupRestoreViewController {
	BOOL _dropboxLoginInProgress;
	BOOL _selectBackupInProgress;
	double _totalBytes;
	BOOL _restoreInProgress;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

	[self loadDropboxInfo];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginWithSuccess) name:A3DropboxLoginWithSuccess object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginFailed) name:A3DropboxLoginFailed object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3DropboxLoginWithSuccess object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3DropboxLoginFailed object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationDidBecomeActive {
	if (_dropboxLoginInProgress) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)dropboxLoginWithSuccess {
	_dropboxLoginInProgress = NO;
	[self loadDropboxInfo];
}

- (void)dropboxLoginFailed {
	_dropboxLoginInProgress = NO;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self isMovingToParentViewController]) {
		if (self.dropboxAccessToken == nil) {
			[self linkDropboxAccount];
		}
	} else if (_selectBackupInProgress) {
		_selectBackupInProgress = NO;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDropboxInfo {
	ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
	NSDictionary *dropboxLinkInfo = [keychain credentialsForUsername:@"dropboxUser" service:@"Dropbox"];
	if (dropboxLinkInfo) {
		NSString *accessToken = [dropboxLinkInfo valueForKey:ACKeychainPassword];
		self.dropboxAccessToken = accessToken;
		[TJDropbox getAccountInformationWithAccessToken:accessToken completion:^(NSDictionary * _Nullable parsedResponse, NSError * _Nullable error) {
			self.dropboxAccountInfo = parsedResponse;
			/*
				Result of get accountInfo
				{
					"account_id" = "dbid:AAB6kLEEbjq3cl2jpKbkuLYtsxBjOPzJ9lE";
					"account_type" =     {
						".tag" = basic;
					};
					country = KR;
					disabled = 0;
					email = "bk.kwak@gmail.com";
					"email_verified" = 1;
					"is_paired" = 0;
					locale = en;
					name =     {
						"abbreviated_name" = SK;
						"display_name" = "Steven Kwak";
						"familiar_name" = Steven;
						"given_name" = Steven;
						surname = Kwak;
					};
					"referral_link" = "https://db.tt/vTskgEAf";
				}
			 */
			[TJDropbox listFolderWithPath:kDropboxDir accessToken:accessToken completion:^(NSArray<NSDictionary *> * _Nullable entries, NSString * _Nullable cursor, NSError * _Nullable error) {
				NSDate *recentModified = nil;
				NSDateFormatter *dateFormatter = [NSDateFormatter new];
				dateFormatter.dateFormat = @"y-MM-dd'T'HH:mm:ss'Z'";
				dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
				for (NSDictionary *file in entries) {
                    if (![[[file[@"name"] componentsSeparatedByString:@"."] lastObject] isEqualToString:@"backup"]) continue;
                    
					NSDate *fileDate = [dateFormatter dateFromString:file[@"server_modified"]];
					if (recentModified == nil) {
						recentModified = fileDate;
					} else if ([recentModified compare:fileDate] == NSOrderedAscending) {
						recentModified = fileDate;
					}
				}
				if (recentModified == nil) {
					self.backupInfoString = nil;
				} else {
					NSDateFormatter *dateFormatter = [NSDateFormatter new];
					if (IS_IPAD) {
						[dateFormatter setDateStyle:NSDateFormatterFullStyle];
						[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
					}
					else {
						[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
						[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
					}
					NSString *dateString = [recentModified timeAgoWithLimit:60*60*24 dateFormatter:dateFormatter];
					self.backupInfoString = [NSString stringWithFormat:NSLocalizedString(@"Last Backup: %@", @"Last Backup: %@"), dateString];

				}
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.tableView reloadData];
				});

				/*
				 (
				 {
				 ".tag" = file;
				 "client_modified" = "2016-05-26T11:34:17Z";
				 id = "id:19_m1EjNZdAAAAAAAAAAAQ";
				 name = "AppBoxBackup-2016-05-26-20-34.backup";
				 "path_display" = "/AllAboutApps/AppBox Pro/AppBoxBackup-2016-05-26-20-34.backup";
				 "path_lower" = "/allaboutapps/appbox pro/appboxbackup-2016-05-26-20-34.backup";
				 rev = 1281412dd97;
				 "server_modified" = "2016-05-26T11:34:17Z";
				 size = 58622;
				 },
				 {
				 ".tag" = file;
				 "client_modified" = "2016-07-26T08:42:45Z";
				 id = "id:2W7D5me6IvgAAAAAAAAAZw";
				 name = "AppBoxBackup-2016-07-26-17-42.backup";
				 "path_display" = "/AllAboutApps/AppBox Pro/AppBoxBackup-2016-07-26-17-42.backup";
				 "path_lower" = "/allaboutapps/appbox pro/appboxbackup-2016-07-26-17-42.backup";
				 rev = 1301412dd97;
				 "server_modified" = "2016-07-26T08:42:45Z";
				 size = 55628;
				 },
				 {
				 ".tag" = file;
				 "client_modified" = "2016-09-29T22:24:05Z";
				 id = "id:2W7D5me6IvgAAAAAAAAAaQ";
				 name = "AppBoxBackup-2016-09-30-07-24.backup";
				 "path_display" = "/AllAboutApps/AppBox Pro/AppBoxBackup-2016-09-30-07-24.backup";
				 "path_lower" = "/allaboutapps/appbox pro/appboxbackup-2016-09-30-07-24.backup";
				 rev = 1321412dd97;
				 "server_modified" = "2016-09-29T22:24:05Z";
				 size = 1730286;
				 }
				 )				 
				 */
			}];
		}];
	}
}

- (void)linkDropboxAccount {
	_dropboxLoginInProgress = YES;
	
    [TJDropboxAuthenticator authenticateWithClientIdentifier:kDropboxClientIdentifier
                                         bypassingNativeAuth:NO
                                               bypassingPKCE:NO
                                                  completion:^(NSString * _Nullable accessToken) {
        
        if (accessToken) {
            [[ACSimpleKeychain defaultKeychain] storeUsername:@"dropboxUser" password:accessToken identifier:@"net.allaboutapps.AppBoxPro" forService:@"Dropbox"];
            FNLOG(@"App linked successfully!");
            [[NSNotificationCenter defaultCenter] postNotificationName:A3DropboxLoginWithSuccess object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:A3DropboxLoginFailed object:nil];
        }
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 2 && _backupInfoString) return 25;
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 1 && _backupInfoString) {
		return 56 - 26;
	}
	BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1 && _backupInfoString) {
		return _backupInfoString;
	}
	return [super tableView:tableView titleForFooterInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (cell.tag == 1100) {
		cell.detailTextLabel.text = _dropboxAccountInfo ? _dropboxAccountInfo[@"name"][@"display_name"] : @"";
	} else {
        cell.textLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	switch (indexPath.section) {
		case 1:
			switch (indexPath.row) {
				case 0:
					if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
																			message:NSLocalizedString(@"Please turn iCloud sync off.", @"Please turn iCloud sync off.")
																		   delegate:nil
																  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
																  otherButtonTitles:nil];
						[alertView show];
					}
					else
					{
						_selectBackupInProgress = YES;
						
						self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
						[self.navigationController.view addSubview:_HUD];
						
						_HUD.mode = MBProgressHUDModeIndeterminate;
						_HUD.removeFromSuperViewOnHide = YES;
						
						_HUD.label.text = NSLocalizedString(@"Loading", nil);
						
						[_HUD showAnimated:YES];
						
						[TJDropbox listFolderWithPath:kDropboxDir accessToken:self.dropboxAccessToken completion:^(NSArray<NSDictionary *> * _Nullable entries, NSString * _Nullable cursor, NSError * _Nullable error) {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K endsWith[cd] '.backup'", @"name"];
                            NSArray *backupFiles = [entries filteredArrayUsingPredicate:predicate];
                            NSSortDescriptor *modifiedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"client_modified" ascending:NO];
                            backupFiles = [backupFiles sortedArrayUsingDescriptors:@[modifiedDescriptor]];
							dispatch_async(dispatch_get_main_queue(), ^{
                                [self->_HUD hideAnimated:YES];
                                self->_HUD = nil;
								
								if (error == nil && [backupFiles count]) {
									self.dropboxFolderList = backupFiles;
									[self performSegueWithIdentifier:@"dropboxSelectBackup" sender:nil];
								} else {
									UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox", @"Dropbox") message:NSLocalizedString(@"You have no backup files stored in Dropbox.", @"You have no backup files stored in Dropbox.") delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
									[alertView show];
								}
								FNLOG(@"%@", entries);
							});
						}];
					}
					break;
				case 1: {
					[self.backupRestoreManager backupData];
					break;
                }
			}
			break;
		case 2:
			[[ACSimpleKeychain defaultKeychain] deleteCredentialsForIdentifier:@"net.allaboutapps.AppBoxPro" service:@"Dropbox"];

			[self.navigationController popViewControllerAnimated:YES];
			break;
	}
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AAAZip Delegate

- (void)decompressProgress:(float)currentByte total:(float)totalByte {
	_HUD.progress = currentByte / totalByte;
	[self.percentFormatter setMaximumFractionDigits:0];
	_HUD.detailsLabel.text = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)completedUnzipProcess:(BOOL)bResult{
	[_HUD hideAnimated:YES];
	_HUD = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:_downloadFilePath error:NULL];
	if (_restoreInProgress) {
		_restoreInProgress = NO;

		self.backupRestoreManager.delegate = self;
		[self.backupRestoreManager restoreDataAt:[@"restore" pathInCachesDirectory] toURL:[fileManager storeURL]];
	}
}

- (void)backupRestoreManager:(A3BackupRestoreManager *)manager restoreCompleteWithSuccess:(BOOL)success {
    [self presentAlertWithTitle:NSLocalizedString(@"Info", @"Info")
                        message:NSLocalizedString(@"Your data has been restored successfully.", nil)];

	NSNumber *selectedColor = [[A3SyncManager sharedSyncManager] objectForKey:A3SettingsUserDefaultsThemeColorIndex];
	if (selectedColor) {
        UIColor *themeColor = [[A3UserDefaults standardUserDefaults] themeColor];
        self.view.tintColor = themeColor;
        [A3AppDelegate instance].window.tintColor = themeColor;
        self.navigationController.navigationBar.tintColor = themeColor;
		[self.tableView reloadData];
	}
}

- (void)backupRestoreManager:(A3BackupRestoreManager *)manager backupCompleteWithSuccess:(BOOL)success {
	[self loadDropboxInfo];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];

	if ([segue.identifier isEqualToString:@"dropboxSelectBackup"]) {
		UINavigationController *navigationController = segue.destinationViewController;
		
		A3SettingsDropboxSelectBackupViewController *viewController = navigationController.viewControllers[0];
		viewController.delegate = self;
		viewController.dropboxFolderList	 = self.dropboxFolderList;
		viewController.dropboxAccessToken = self.dropboxAccessToken;
	}
}

#pragma mark - A3DropboxSelectBackupDelegate

- (void)dropboxSelectBackupViewController:(UIViewController *)vc backupFileSelected:(NSDictionary *)metadata {
	[vc dismissViewControllerAnimated:YES completion:nil];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	self.downloadFilePath = [NSString stringWithFormat:@"%@/%@", paths[0], metadata[@"name"]];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:_downloadFilePath]) {
		[fileManager removeItemAtPath:_downloadFilePath error:nil];
	}

	self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_HUD];

	// Set determinate mode
	_HUD.mode = MBProgressHUDModeDeterminate;
	_HUD.removeFromSuperViewOnHide = YES;

	_HUD.label.text = NSLocalizedString(@"Downloading", @"Downloading");

	[_HUD showAnimated:YES];

	_totalBytes = [metadata[@"size"] doubleValue];
    __weak __typeof__(self) weakSelfProgress = self;
    __weak __typeof__(self) weakSelfCompletion = self;
	[TJDropbox downloadFileAtPath:metadata[@"path_display"] toPath:_downloadFilePath accessToken:self.dropboxAccessToken
					progressBlock:^(CGFloat progress) {
						dispatch_async(dispatch_get_main_queue(), ^{
                            __typeof__(self) strongSelf = weakSelfProgress;
                            strongSelf.HUD.progress = progress;
							[strongSelf.percentFormatter setMaximumFractionDigits:0];
                            strongSelf.HUD.detailsLabel.text = [strongSelf.percentFormatter stringFromNumber:@(progress)];
						});
					}
					   completion:^(NSDictionary * _Nullable parsedResponse, NSError * _Nullable error) {
						   dispatch_async(dispatch_get_main_queue(), ^{
                               __typeof__(self) strongSelf = weakSelfCompletion;
							   if (error == nil) {
								   strongSelf.restoreInProgress = YES;
                                   strongSelf.HUD.label.text = NSLocalizedString(@"Unarchiving", @"Unarchiving");
								   AAAZip *zipArchive = [[AAAZip alloc] init];
								   zipArchive.delegate = self;
								   [zipArchive unzipFile:strongSelf.downloadFilePath unzipFileto:[@"restore" pathInCachesDirectory]];
							   } else {
								   FNLOG(@"%@", error.localizedDescription);
                                   [self presentAlertWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Failed to download backup file.", @"Failed to download backup file.")];
								   [strongSelf.HUD hideAnimated:YES];
                                   strongSelf.HUD = nil;
							   }
						   });
	}];
}

#pragma mark - Backup Restore Manager

- (A3BackupRestoreManager *)backupRestoreManager {
	if (!_backupRestoreManager) {
		_backupRestoreManager = [A3BackupRestoreManager new];
		_backupRestoreManager.delegate = self;
		_backupRestoreManager.hostingView = self.navigationController.view;
		_backupRestoreManager.hostingViewController = self;
	}
	return _backupRestoreManager;
}

@end
