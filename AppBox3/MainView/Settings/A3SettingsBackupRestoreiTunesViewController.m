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
@import UniformTypeIdentifiers;
#import "UIViewController+A3Addition.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3SettingsBackupRestoreiTunesViewController () <A3SettingsITunesSelectBackupDelegate, AAAZipDelegate, A3BackupRestoreManagerDelegate, UIDocumentPickerDelegate>

@property (nonatomic, strong) NSString *backupInfoString;
@property (nonatomic, strong) A3BackupRestoreManager *backupRestoreManager;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSURL *backupFileURLFromFiles;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) AAAZip *zipArchive;
@property (nonatomic, strong) FileDownloadManager *downloadManager;

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
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)updateBackupInfo {
    _backupInfoString = @"";

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

	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	if (IS_IPAD) {
		[dateFormatter setDateStyle:NSDateFormatterFullStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	else {
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	NSString *dateString = [attribute.fileCreationDate timeAgoWithLimit:60*60*24 dateFormatter:dateFormatter];
	_backupInfoString = [NSString stringWithFormat:NSLocalizedString(@"Last Backup: %@", @"Last Backup: %@"), dateString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self updateBackupInfo];
	[self.tableView reloadData];
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
	return [super tableView:tableView heightForFooterInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return section == 0 ? _backupInfoString : [super tableView:tableView titleForFooterInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) { 	// Restore
            UTType *type = [UTType exportedTypeWithIdentifier:@"net.allaboutapps.appboxbackup"];
            UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[type]];
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:NULL];
		} else {					// Backup
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", @"Info")
                                                message:NSLocalizedString(@"This will take a while. Would you like to continue?", @"")
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", @"")
                                     style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction * _Nonnull action) {
                self.downloadManager = [[FileDownloadManager alloc] init];
                [self.backupRestoreManager backupToDocumentDirectory:self.downloadManager];
            }];
            UIAlertAction *cancelAction =
            [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                     style:UIAlertActionStyleCancel
                                   handler:NULL];
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:NULL];
		}
	} else {
		[[UIApplication sharedApplication] openURL2:[NSURL URLWithString:@"http://www.allaboutapps.net/wordpress/archives/358"]];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[[UIApplication sharedApplication] openURL2:[NSURL URLWithString:@"http://www.allaboutapps.net/wordpress/archives/358"]];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        cell.textLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    UIAlertAction *replaceAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Replace", nil)
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * _Nonnull action) {
        [self proceedRestoreWithFileURL:urls[0]];
    }];
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:NULL];
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@""
                                        message:NSLocalizedString(@"Are you going to replace existing data with the backup data?", nil)
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:replaceAction];
    [alertController addAction:cancelAction];

    if (IS_IPAD) {
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        popover.sourceView = self.view;
        UITableViewCell *senderCell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        popover.sourceRect = CGRectMake(self.view.center.x, ((UITableViewCell *)senderCell).center.y, 0, 0);
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)proceedRestoreWithFileURL:(NSURL *)fileURL {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_HUD];

    _HUD.mode = MBProgressHUDModeIndeterminate;
    _HUD.label.text = NSLocalizedString(@"Copying...", nil);

    [_HUD showAnimated:YES];

    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            NSString *filename = [fileURL lastPathComponent];
            self.backupFileURLFromFiles = [NSURL fileURLWithPath:[filename pathInCachesDirectory]];
            
            NSError *error;
            if (![fileURL startAccessingSecurityScopedResource]) {
                BOOL urlAvailable = NO;
                do {
                    urlAvailable = [fileURL startAccessingSecurityScopedResource];
                } while (!urlAvailable);
            }
            [fileCoordinator coordinateReadingItemAtURL:fileURL
                                                options:NSFileCoordinatorReadingWithoutChanges
                                       writingItemAtURL:self.backupFileURLFromFiles
                                                options:NSFileCoordinatorWritingForReplacing
                                                  error:&error
                                             byAccessor:^(NSURL * _Nonnull newReadingURL, NSURL * _Nonnull newWritingURL) {
                NSFileManager *manager = [NSFileManager defaultManager];
                NSError *copyError;
                [manager copyItemAtURL:newReadingURL toURL:newWritingURL error:&copyError];
                if (copyError) {
                    FNLOG(@"%@", copyError.description);
                }
            }];
            [fileURL stopAccessingSecurityScopedResource];
        }

        // Set determinate mode
        self.HUD.mode = MBProgressHUDModeDeterminate;
        self.HUD.removeFromSuperViewOnHide = YES;

        self.HUD.label.text = NSLocalizedString(@"Unarchiving", @"Unarchiving");

        [self.HUD showAnimated:YES];

        self.zipArchive = [[AAAZip alloc] init];
        self.zipArchive.delegate = self;
        [self.zipArchive unzipFile:[self.backupFileURLFromFiles path] unzipFileto:[@"restore" pathInCachesDirectory]];
    });

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
		_backupRestoreManager.delegate = self;
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

	_HUD.label.text = NSLocalizedString(@"Unarchiving", @"Unarchiving");

	[_HUD showAnimated:YES];

	AAAZip *zipArchive = [[AAAZip alloc] init];
	zipArchive.delegate = self;
	[zipArchive unzipFile:[filename pathInDocumentDirectory] unzipFileto:[@"restore" pathInCachesDirectory]];
}

- (void)decompressProgress:(float)currentByte total:(float)totalByte {
	_HUD.progress = (float) MIN(currentByte / totalByte, 1.0);
	[self.percentFormatter setMaximumFractionDigits:0];
	_HUD.detailsLabel.text = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)completedUnzipProcess:(BOOL)bResult{
	[_HUD hideAnimated:YES];
	_HUD = nil;

    // Delete backup file copied from Files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:self.backupFileURLFromFiles error:NULL];

    if (bResult) {
        self.backupRestoreManager.delegate = self;
        [self.backupRestoreManager restoreDataAt:[@"restore" pathInCachesDirectory]];
    } else {
        [self presentAlertWithTitle:NSLocalizedString(@"Info", @"Info") message:NSLocalizedString(@"The restoring process failed to unarchive the backup file.", @"")];
    }
    self.zipArchive = nil;
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
	if (success) {
		[self updateBackupInfo];
		[self.tableView reloadData];
	}
}

@end
