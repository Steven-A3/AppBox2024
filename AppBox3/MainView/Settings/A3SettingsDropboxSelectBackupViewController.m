//
//  A3SettingsDropboxSelectBackupViewController.m
//  AppBox3
//
//  Created by A3 on 1/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "A3SettingsDropboxSelectBackupViewController.h"
#import "NSDate+TimeAgo.h"
#import "MBProgressHUD.h"
#import "UITableViewController+standardDimension.h"

@interface A3SettingsDropboxSelectBackupViewController () <UIActionSheetDelegate, DBRestClientDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation A3SettingsDropboxSelectBackupViewController {
	NSUInteger _selectedIndex;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (DBRestClient *)restClient {
	if (!_restClient) {
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropboxMetadata.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"dropboxFilesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	DBMetadata *rowData = self.dropboxMetadata.contents[indexPath.row];
    cell.textLabel.text = rowData.filename;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [rowData.lastModifiedDate timeAgo], rowData.humanReadableSize];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	_selectedIndex = (NSUInteger) indexPath.row;

	UIActionSheet *confirmRestore = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you going to replace existing data with the backup data?", @"")
																delegate:self
													   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
												  destructiveButtonTitle:NSLocalizedString( @"Replace", @"")
													   otherButtonTitles:nil];
	confirmRestore.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[confirmRestore showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		DBMetadata *selectedData = self.dropboxMetadata.contents[_selectedIndex];
		if ([_delegate respondsToSelector:@selector(dropboxSelectBackupViewController:backupFileSelected:)]) {
			[_delegate dropboxSelectBackupViewController:self backupFileSelected:selectedData];
		}
	}
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		DBMetadata *metadata = self.dropboxMetadata.contents[indexPath.row];
		[self.restClient deletePath:metadata.path];

		self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		_hud.removeFromSuperViewOnHide = YES;
		[self.navigationController.view addSubview:_hud];

		_hud.labelText = @"Deleting";
		[_hud show:YES];
	}
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	self.dropboxMetadata = metadata;
	[self.tableView reloadData];
}

extern NSString *const kDropboxDir;

- (void)restClient:(DBRestClient *)client deletedPath:(NSString *)path {
	[_hud hide:YES];
	_hud = nil;

	[self.restClient loadMetadata:kDropboxDir];
}

- (void)restClient:(DBRestClient *)client deletePathFailedWithError:(NSError *)error {
	[_hud hide:YES];
	_hud = nil;

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dropbox" message:@"Unable to delete selected file. Please try it again." delegate:nil cancelButtonTitle:@"Dismies" otherButtonTitles:nil];
	[alertView show];
}

@end
