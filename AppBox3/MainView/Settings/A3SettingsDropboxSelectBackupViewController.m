//
//  A3SettingsDropboxSelectBackupViewController.m
//  AppBox3
//
//  Created by A3 on 1/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsDropboxSelectBackupViewController.h"
#import "NSDate+TimeAgo.h"
#import "MBProgressHUD.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"
#import "TJDropbox.h"
#import "NSFileManager+A3Addition.h"
#import "A3UIDevice.h"

extern NSString *const kDropboxDir;

@interface A3SettingsDropboxSelectBackupViewController () <UIActionSheetDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *parseFormatter;

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
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:18]};
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
	self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
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

- (NSDateFormatter *)parseFormatter {
	if (!_parseFormatter) {
		_parseFormatter = [NSDateFormatter new];
		_parseFormatter.dateFormat = @"y-MM-dd'T'HH:mm:ss'Z'";
		_parseFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	}
	return _parseFormatter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropboxFolderList count];
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

	NSDictionary *rowData = self.dropboxFolderList[indexPath.row];
    cell.textLabel.text = rowData[@"name"];
	NSDate *fileDate = [self.parseFormatter dateFromString:rowData[@"server_modified"]];
	long long fileSize = [rowData[@"size"] longLongValue];
	NSString *humanReadableFilesize = [[NSFileManager defaultManager] humanReadableFileSize:fileSize];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [fileDate timeAgoWithLimit:60*60*24 dateFormatter:self.dateFormatter], humanReadableFilesize];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	_selectedIndex = (NSUInteger) indexPath.row;

    if (IS_IPAD) {
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
    {
        [self showReplaceActionSheet];
    }
}

- (void)selectBackUpFileAction {
    NSDictionary *selectedData = self.dropboxFolderList[_selectedIndex];
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
		NSDictionary *metadata = self.dropboxFolderList[indexPath.row];
		self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		_hud.removeFromSuperViewOnHide = YES;
		[self.navigationController.view addSubview:_hud];
		
		_hud.label.text = NSLocalizedString(@"Deleting", @"Deleting");
		[_hud showAnimated:YES];
		
		[TJDropbox deleteFileAtPath:metadata[@"path_display"] accessToken:self.dropboxAccessToken completion:^(NSDictionary * _Nullable parsedResponse, NSError * _Nullable error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[TJDropbox listFolderWithPath:kDropboxDir accessToken:self.dropboxAccessToken completion:^(NSArray<NSDictionary *> * _Nullable entries, NSString * _Nullable cursor, NSError * _Nullable error) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_hud hideAnimated:YES];
						_hud = nil;
						
						self.dropboxFolderList = entries;
						[self.tableView reloadData];
					});
				}];
			});
		}];
	}
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

@end
