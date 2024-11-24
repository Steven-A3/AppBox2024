//
//  A3SettingsiTunesSelectBackupViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsiTunesSelectBackupViewController.h"
#import "NSFileManager+A3Addition.h"
#import "NSString+conversion.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"
#import "A3UIDevice.h"

@interface A3SettingsiTunesSelectBackupViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *backupFiles;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation A3SettingsiTunesSelectBackupViewController {
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

#pragma mark - Prepare data

- (NSArray *)backupFiles {
	if (!_backupFiles) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *documentDirectoryPath = [fileManager documentDirectoryPath];

		NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:documentDirectoryPath error:NULL];
		NSPredicate *backupFilePredicate = [NSPredicate predicateWithFormat:@"self endswith[cd] %@", @".backup"];
		NSArray *backupContents = [directoryContents filteredArrayUsingPredicate:backupFilePredicate];
		_backupFiles = [backupContents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			return [obj2 compare:obj1];
		}];
	}
	return _backupFiles;
}


- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
		if (IS_IPAD) {
			[_dateFormatter setDateStyle:NSDateFormatterFullStyle];
			[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
		} else {
			[_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
		}
	}
	return _dateFormatter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.backupFiles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"backupFileCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *filename = self.backupFiles[indexPath.row];
	cell.textLabel.text = filename;
	NSDictionary *attribute = [fileManager attributesOfItemAtPath:[filename pathInDocumentDirectory] error:NULL];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [attribute.fileCreationDate timeAgoWithLimit:60*60*24 dateFormatter:self.dateFormatter], [fileManager humanReadableFileSize:attribute.fileSize]];

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
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		[fileManager removeItemAtPath:[_backupFiles[indexPath.row] pathInDocumentDirectory] error:&error];
		if (!error) {
			_backupFiles = nil;
			[self.tableView reloadData];
		} else {
            [[UIApplication sharedApplication] showAlertWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription];
		}
	}
}

- (void)selectBackUpFileAction {
	if ([_delegate respondsToSelector:@selector(iTunesSelectBackupViewController:backupFileSelected:)]) {
		[_delegate iTunesSelectBackupViewController:self backupFileSelected:self.backupFiles[_selectedIndex]];
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

@end
