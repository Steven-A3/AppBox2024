//
//  A3SettingsSyncViewController.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsSyncViewController.h"
#import "A3AppDelegate.h"
#import "A3AppDelegate+iCloud.h"
#import "A3SettingsDropboxSelectBackupViewController.h"
#import <DropboxSDK/DropboxSDK.h>

NSString *const kDropboxDir = @"/AllAboutApps/AppBox Pro";

@interface A3SettingsSyncViewController () <DBSessionDelegate, DBRestClientDelegate, A3SettingsDropboxSelectBackupDelegate>

@property (nonatomic, strong) UISwitch *iCloudSwitch;
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) DBAccountInfo *dropboxAccountInfo;
@property (nonatomic, strong) DBMetadata *dropboxMetadata;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation A3SettingsSyncViewController {
	BOOL _dropboxLoginInProgress;
	BOOL _selectBackupInProgress;
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

	NSString* appKey = @"ody0cjvmnaxvob4";
	NSString* appSecret = @"4hbzpvkrlwhs9qh";
	NSString *root = kDBRootDropbox; // Should be set to either kDBRootAppFolder or kDBRootDropbox

	DBSession* session =
			[[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive)
												 name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
}

- (void)applicationDidBecomeActive {
	if (_dropboxLoginInProgress) {
		_dropboxLoginInProgress = NO;
		
		[self.restClient loadAccountInfo];
		[self.restClient loadMetadata:kDropboxDir];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self isMovingToParentViewController]) {
		if ([[DBSession sharedSession] isLinked]) {
			[self.restClient loadAccountInfo];
			[self.restClient loadMetadata:kDropboxDir];
		}
	} else if (_dropboxLoginInProgress) {
		_dropboxLoginInProgress = NO;

		if ([[DBSession sharedSession] isLinked]) {
			[self.restClient loadAccountInfo];
			[self.restClient loadMetadata:kDropboxDir];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (cell.tag == 1100) {
		if (!_iCloudSwitch) {
			_iCloudSwitch = [UISwitch new];
			[_iCloudSwitch setEnabled:[[A3AppDelegate instance].ubiquityStoreManager cloudAvailable]];
			_iCloudSwitch.on = [[A3AppDelegate instance].ubiquityStoreManager cloudEnabled];
			[_iCloudSwitch addTarget:self action:@selector(toggleCloud:) forControlEvents:UIControlEventValueChanged];
		}
		cell.accessoryView = _iCloudSwitch;
	} else if (indexPath.section == 1) {
		if ([[DBSession sharedSession] isLinked]) {
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Backup";
					break;
				case 1:
					cell.textLabel.text = @"Restore";
					break;
				case 2:
					cell.textLabel.text = @"Unlink Account";
					break;
			}
		} else {
			cell.textLabel.text = @"Link Account";
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1) {
		return [[DBSession sharedSession] isLinked] ? 3 : 1;
	}
	return [super tableView:tableView numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		if (![[A3AppDelegate instance].ubiquityStoreManager cloudAvailable]) {
			return @"Enable iCloud and Documents and Data storages in your Settings to gain access to this feature.";
		}
	} else if (section == 1) {
		if ([[DBSession sharedSession] isLinked] && self.dropboxAccountInfo) {
			return [NSString stringWithFormat:@"AppBox Pro™ is linked to [%@] Dropbox accont.", self.dropboxAccountInfo.displayName];
		}
	}
	return nil;
}

- (void)toggleCloud:(UISwitch *)switchControl {
	[[A3AppDelegate instance] setCloudEnabled:switchControl.on];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0:
				if ([[DBSession sharedSession] isLinked]) {
					// Do backup
				} else {
					_dropboxLoginInProgress = YES;
					[[DBSession sharedSession] linkFromController:self];
				}
				break;
			case 1:
				// Restore from backup
				_selectBackupInProgress = YES;
				[self.restClient loadMetadata:kDropboxDir];
				break;
			case 2:
				// Unlink
				[[DBSession sharedSession] unlinkAll];
				
				self.dropboxAccountInfo = Nil;
				[self.tableView reloadData];
				break;
		}
	}
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

	[self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	DBMetadata *metaDataOfLastObject = [metadata.contents lastObject];
	FNLOG(@"%@, %@, %@, %@", metaDataOfLastObject.path, metaDataOfLastObject.filename, metaDataOfLastObject.humanReadableSize, [metaDataOfLastObject.lastModifiedDate description]);
	if (_selectBackupInProgress) {
		if (![metadata.contents count]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dropbox" message:@"You have no backup files stored in Dropbox." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alertView show];
		} else {
			self.dropboxMetadata = metadata;
			[self performSegueWithIdentifier:@"dropboxSelectBackup" sender:nil];
		}
	}
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
	[_HUD hide:YES];
	_HUD = nil;
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
	_HUD.progress = progress;
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
	[_HUD hide:YES];
	_HUD = nil;
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
	NSString *downloadFilePath = [NSString stringWithFormat:@"%@/%@", paths[0], metadata.filename];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:downloadFilePath]) {
		[fileManager removeItemAtPath:downloadFilePath error:nil];
	}

	[self.restClient loadFile:metadata.path intoPath:downloadFilePath];

	self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_HUD];

	// Set determinate mode
	_HUD.mode = MBProgressHUDModeDeterminate;
	_HUD.removeFromSuperViewOnHide = YES;

	_HUD.labelText = @"Downloading";

	[_HUD show:YES];

}



@end
