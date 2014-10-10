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
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"

@interface A3SettingsDropboxSelectBackupViewController () <UIActionSheetDelegate, DBRestClientDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
		if (IS_IPAD) {
			[_dateFormatter setDateStyle:NSDateFormatterFullStyle];
			[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		} else {
			[_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		}
	}
	return _dateFormatter;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"dropboxFilesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

	DBMetadata *rowData = self.dropboxMetadata.contents[indexPath.row];
    cell.textLabel.text = rowData.filename;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [rowData.lastModifiedDate timeAgoWithLimit:60*60*24 dateFormatter:self.dateFormatter], rowData.humanReadableSize];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	_selectedIndex = (NSUInteger) indexPath.row;


#ifdef __IPHONE_8_0
    if (!IS_IOS7 && IS_IPAD) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Are you going to replace existing data with the backup data?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString( @"Replace", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self selectBackUpFileAction];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:NULL];
        }]];
        alertController.modalInPopover = UIModalPresentationPopover;
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        CGRect fromRect = [self.tableView convertRect:cell.bounds fromView:cell];
        fromRect.origin.x = self.view.center.x;
        fromRect.origin.y = fromRect.origin.y + 22.0;
        fromRect.size = CGSizeZero;
        popover.sourceView = self.view;
        popover.sourceRect = fromRect;
        popover.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
        
        [self presentViewController:alertController animated:YES completion:NULL];
    }
    else
#endif
    {
        [self showReplaceActionSheet];
    }
}

- (void)selectBackUpFileAction {
    DBMetadata *selectedData = self.dropboxMetadata.contents[_selectedIndex];
    if ([_delegate respondsToSelector:@selector(dropboxSelectBackupViewController:backupFileSelected:)]) {
        [_delegate dropboxSelectBackupViewController:self backupFileSelected:selectedData];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self setFirstActionSheet:nil];
    
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self selectBackUpFileAction];
	}
}

#pragma mark ActionSheet Rotation Related

- (void)rotateFirstActionSheet {
    NSInteger currentActionSheetTag = [self.firstActionSheet tag];
    [super rotateFirstActionSheet];
    [self setFirstActionSheet:nil];
    
    [self showActionSheetAdaptivelyInViewWithTag:currentActionSheetTag];
}

- (void)showActionSheetAdaptivelyInViewWithTag:(NSInteger)actionSheetTag {
    switch (actionSheetTag) {
        case 0:
            [self showReplaceActionSheet];
            break;
            
        default:
            break;
    }
}

- (void)showReplaceActionSheet {
    UIActionSheet *confirmRestore = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you going to replace existing data with the backup data?", @"")
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                  destructiveButtonTitle:NSLocalizedString( @"Replace", @"")
                                                       otherButtonTitles:nil];
    confirmRestore.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [confirmRestore showInView:self.view];
    confirmRestore.tag = 0;
    [self setFirstActionSheet:confirmRestore];
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

		_hud.labelText = NSLocalizedString(@"Deleting", @"Deleting");
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

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox", @"Dropbox")
														message:NSLocalizedString(@"Unable to delete selected file. Please try it again.", @"Unable to delete selected file. Please try it again.")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
}

@end
