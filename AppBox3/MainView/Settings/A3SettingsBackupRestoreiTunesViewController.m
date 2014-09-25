//
//  A3SettingsBackupRestoreiTunesViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsBackupRestoreiTunesViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSFileManager+A3Addition.h"
#import "A3BackupRestoreManager.h"
#import "NSString+conversion.h"
#import "NSDate+TimeAgo.h"
#import "A3SettingsiTunesSelectBackupViewController.h"
#import "MBProgressHUD.h"
#import "AAAZip.h"
#import "A3AppDelegate.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@interface A3SettingsBackupRestoreiTunesViewController () <A3SettingsITunesSelectBackupDelegate, AAAZipDelegate, A3BackupRestoreManagerDelegate>

@property (nonatomic, strong) NSString *backupInfoString;
@property (nonatomic, strong) A3BackupRestoreManager *backupRestoreManager;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation A3SettingsBackupRestoreiTunesViewController

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
}

- (void)updateBackupInfo {
	_backupInfoString = NSLocalizedString(@"Backup file does not exist.", @"No backup files.");

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *documentDirectoryPath = [fileManager documentDirectoryPath];
	NSArray *backupFiles = [fileManager contentsOfDirectoryAtPath:documentDirectoryPath error:NULL];
	FNLOG(@"%@", backupFiles);

	if (![backupFiles count]) {
		return;
	}

	NSPredicate *backupFilePredicate = [NSPredicate predicateWithFormat:@"self endswith[cd] %@", @".backup"];
	backupFiles = [backupFiles filteredArrayUsingPredicate:backupFilePredicate];

	NSArray *V3BackupFiles, *V1BackupFiles;
	if ([backupFiles count]) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self beginswith[cd] %@", @"AppBoxBackup"];
		V3BackupFiles = [backupFiles filteredArrayUsingPredicate:predicate];
		if ([V3BackupFiles count]) {
			NSArray *sortedArray = [V3BackupFiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				return [obj1 compare:obj2];
			}];
			[self setBackupInfoWithFilename:[sortedArray lastObject]];
		} else {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self beginswith[cd] %@", @"AppBoxPro."];
			V1BackupFiles = [backupFiles filteredArrayUsingPredicate:predicate];
			if ([V1BackupFiles count]) {
				NSArray *sortedArray = [V1BackupFiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
					return [obj1 compare:obj2];
				}];
				[self setBackupInfoWithFilename:[sortedArray lastObject]];
			} else {
				NSArray *sortedArray = [backupFiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
					return [obj1 compare:obj2];
				}];
				[self setBackupInfoWithFilename:[sortedArray lastObject]];
			}
		}
	}
}

- (void)setBackupInfoWithFilename:(NSString *)filename {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDictionary *attribute = [fileManager attributesOfItemAtPath:[filename pathInDocumentDirectory]
															error:NULL];
	_backupInfoString = [NSString stringWithFormat:NSLocalizedString(@"Last Backup: %@", @"Last Backup: %@"), [attribute.fileCreationDate timeAgo]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self updateBackupInfo];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2 && _backupInfoString) return 25;
    return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 && _backupInfoString) {
        return 56 - 26;
    }
    BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
    return [self standardHeightForFooterIsLastSection:isLastSection];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return section == 0 ? _backupInfoString : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) { 	// Restore

		} else {					// Backup
			[self.backupRestoreManager backupToDocumentDirectory];
		}
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.allaboutapps.net/wordpress/archives/358"]];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        cell.textLabel.textColor = [[A3AppDelegate instance] themeColor];
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Backup Restore Manager

- (A3BackupRestoreManager *)backupRestoreManager {
	if (!_backupRestoreManager) {
		_backupRestoreManager = [A3BackupRestoreManager new];
		_backupRestoreManager.hostingView = self.navigationController.view;
		_backupRestoreManager.hostingViewController = self;
	}
	return _backupRestoreManager;
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];

	if ([segue.identifier isEqualToString:@"iTunesSelectBackup"]) {
		UINavigationController *navigationController = segue.destinationViewController;

		A3SettingsiTunesSelectBackupViewController *viewController = navigationController.viewControllers[0];
		viewController.delegate = self;
	}
}

- (void)iTunesSelectBackupViewController:(UIViewController *)vc backupFileSelected:(NSString *)filename {
	[vc dismissViewControllerAnimated:YES completion:nil];

	self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_HUD];

	// Set determinate mode
	_HUD.mode = MBProgressHUDModeDeterminate;
	_HUD.removeFromSuperViewOnHide = YES;

	_HUD.labelText = NSLocalizedString(@"Unarchiving", @"Unarchiving");

	[_HUD show:YES];

	AAAZip *zipArchive = [[AAAZip alloc] init];
	zipArchive.delegate = self;
	[zipArchive unzipFile:[filename pathInDocumentDirectory] unzipFileto:[@"restore" pathInCachesDirectory]];
}

- (void)decompressProgress:(float)currentByte total:(float)totalByte {
	_HUD.progress = currentByte / totalByte;
	[self.percentFormatter setMaximumFractionDigits:0];
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)completedUnzipProcess:(BOOL)bResult{
	[_HUD hide:YES];
	_HUD = nil;

	self.backupRestoreManager.delegate = self;
	[self.backupRestoreManager restoreDataAt:[@"restore" pathInCachesDirectory] toURL:[[A3AppDelegate instance] storeURL]];
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

@end
