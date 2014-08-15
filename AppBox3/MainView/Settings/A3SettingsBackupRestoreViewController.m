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
#import <DropboxSDK/DropboxSDK.h>

NSString *const kDropboxDir = @"/AllAboutApps/AppBox Pro";

@interface A3SettingsBackupRestoreViewController () <DBSessionDelegate, DBRestClientDelegate, A3SettingsDropboxSelectBackupDelegate, AAAZipDelegate, A3BackupRestoreManagerDelegate>

@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) DBAccountInfo *dropboxAccountInfo;
@property (nonatomic, strong) DBMetadata *dropboxMetadata;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *backupInfoString;
@property (nonatomic, strong) A3BackupRestoreManager *backupRestoreManager;
@property (nonatomic, copy) NSString *downloadFilePath;

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

	NSString* appKey = @"ody0cjvmnaxvob4";
	NSString* appSecret = @"4hbzpvkrlwhs9qh";
	NSString *root = kDBRootDropbox; // Should be set to either kDBRootAppFolder or kDBRootDropbox

	DBSession* session =
			[[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];

	if ([[DBSession sharedSession] isLinked]) {
		[self.restClient loadAccountInfo];
		[self.restClient loadMetadata:kDropboxDir];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginWithSuccess) name:A3DropboxLoginWithSuccess object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginFailed) name:A3DropboxLoginFailed object:nil];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3DropboxLoginWithSuccess object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3DropboxLoginFailed object:nil];
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
	if ([[DBSession sharedSession] isLinked]) {
		[self.restClient loadAccountInfo];
		[self.restClient loadMetadata:kDropboxDir];
	}
}

- (void)dropboxLoginFailed {
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self isMovingToParentViewController]) {
		if (![[DBSession sharedSession] isLinked]) {
			_dropboxLoginInProgress = YES;
			[[DBSession sharedSession] linkFromController:self];
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
		cell.detailTextLabel.text = self.dropboxAccountInfo ? _dropboxAccountInfo.displayName : @"";
	} else {
		cell.textLabel.textColor = [[A3AppDelegate instance] themeColor];
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
					} else {
						_selectBackupInProgress = YES;
						[self.restClient loadMetadata:kDropboxDir];
					}
					break;
				case 1: {
					[self.backupRestoreManager backupData];
					break;
				}
			}
			break;
		case 2:
			[[DBSession sharedSession] unlinkAll];
			[self.navigationController popViewControllerAnimated:YES];
			break;
	}
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Dropbox Client

- (DBRestClient *)restClient {
	if (!_restClient) {
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

#pragma mark - Dropbox DBSessionDelegate

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info {
	self.dropboxAccountInfo = info;
	[self.restClient loadMetadata:kDropboxDir];

	[self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	self.dropboxMetadata = metadata;
	if (_selectBackupInProgress) {
		if (![metadata.contents count]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox", @"Dropbox") message:NSLocalizedString(@"You have no backup files stored in Dropbox.", @"You have no backup files stored in Dropbox.") delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alertView show];
		} else {
			[self performSegueWithIdentifier:@"dropboxSelectBackup" sender:nil];
		}
	} else {
		FNLOG(@"%@", self.dropboxMetadata);
		FNLOG(@"%@", metadata.lastModifiedDate);
		FNLOG(@"%@", metadata.contents);
		if (![metadata.contents count]) {
			_backupInfoString = nil;
		} else {
			[metadata.contents enumerateObjectsUsingBlock:^(DBMetadata *fileData, NSUInteger idx, BOOL *stop) {
				FNLOG(@"%@", fileData.filename);
				FNLOG(@"%@", fileData.lastModifiedDate);
			}];
			NSArray *sortedArray = [metadata.contents sortedArrayUsingComparator:^NSComparisonResult(DBMetadata *file1, DBMetadata *file2) {
				return [file1.lastModifiedDate compare:file2.lastModifiedDate];
			}];
			DBMetadata *lastItem = [sortedArray lastObject];
			
            if (IS_IPAD) {
                _backupInfoString = [NSString stringWithFormat:NSLocalizedString(@"Last Backup: %@", @"Last Backup: %@"), [self fullStyleDateStringFromDate:lastItem.lastModifiedDate withShortTime:YES]];
            }
            else {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                _backupInfoString = [NSString stringWithFormat:NSLocalizedString(@"Last Backup: %@", @"Last Backup: %@"), [dateFormatter stringFromDate:lastItem.lastModifiedDate]];
            }
		}

		[self.tableView reloadData];
	}
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
	_restoreInProgress = YES;
	_HUD.labelText = NSLocalizedString(@"Unarchiving", @"Unarchiving");
	AAAZip *zipArchive = [[AAAZip alloc] init];
	zipArchive.delegate = self;
	[zipArchive unzipFile:destPath unzipFileto:[@"restore" pathInCachesDirectory]];
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
	_HUD.progress = progress;
	[self.percentFormatter setMaximumFractionDigits:0];
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(progress)];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
														message:NSLocalizedString(@"Failed to download backup file.", @"Failed to download backup file.")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
	[_HUD hide:YES];
	_HUD = nil;
}

#pragma mark - AAAZip Delegate

- (void)decompressProgress:(float)currentByte total:(float)totalByte {
	_HUD.progress = currentByte / totalByte;
	[self.percentFormatter setMaximumFractionDigits:0];
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)completedUnzipProcess:(BOOL)bResult{
	[_HUD hide:YES];
	_HUD = nil;
	NSFileManager *fileManager = [NSFileManager new];
	[fileManager removeItemAtPath:_downloadFilePath error:NULL];
	if (_restoreInProgress) {
		_restoreInProgress = NO;

		self.backupRestoreManager.delegate = self;
		[self.backupRestoreManager restoreDataAt:[@"restore" pathInCachesDirectory] toURL:[[A3AppDelegate instance] storeURL]];
	}
}

- (void)backupRestoreManager:(A3BackupRestoreManager *)manager restoreCompleteWithSuccess:(BOOL)success {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:NSLocalizedString(@"Your data has been restored successfully.", nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];

	NSNumber *selectedColor = [[A3SyncManager sharedSyncManager] objectForKey:A3SettingsUserDefaultsThemeColorIndex];
	if (selectedColor) {
		self.view.tintColor = [[A3AppDelegate instance] themeColor];
		[A3AppDelegate instance].window.tintColor = [[A3AppDelegate instance] themeColor];
		self.navigationController.navigationBar.tintColor = [[A3AppDelegate instance] themeColor];
		[self.tableView reloadData];
	}
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];

	if ([segue.identifier isEqualToString:@"dropboxSelectBackup"]) {
		UINavigationController *navigationController = segue.destinationViewController;
		
		A3SettingsDropboxSelectBackupViewController *viewController = navigationController.viewControllers[0];
		viewController.delegate = self;
		viewController.dropboxMetadata = self.dropboxMetadata;
	}
}

#pragma mark - A3DropboxSelectBackupDelegate

- (void)dropboxSelectBackupViewController:(UIViewController *)vc backupFileSelected:(DBMetadata *)metadata {
	[vc dismissViewControllerAnimated:YES completion:nil];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	self.downloadFilePath = [NSString stringWithFormat:@"%@/%@", paths[0], metadata.filename];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:_downloadFilePath]) {
		[fileManager removeItemAtPath:_downloadFilePath error:nil];
	}

	_totalBytes = metadata.totalBytes;
	[self.restClient loadFile:metadata.path intoPath:_downloadFilePath];

	self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_HUD];

	// Set determinate mode
	_HUD.mode = MBProgressHUDModeDeterminate;
	_HUD.removeFromSuperViewOnHide = YES;

	_HUD.labelText = NSLocalizedString(@"Downloading", @"Downloading");

	[_HUD show:YES];
}

#pragma mark - Backup Restore Manager

- (A3BackupRestoreManager *)backupRestoreManager {
	if (!_backupRestoreManager) {
		_backupRestoreManager = [A3BackupRestoreManager new];
		_backupRestoreManager.hostingView = self.navigationController.view;
	}
	return _backupRestoreManager;
}

@end
