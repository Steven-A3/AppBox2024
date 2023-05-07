//
//  A3SettingsRecentToKeepViewController.m
//  AppBox3
//
//  Created by A3 on 1/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsRecentToKeepViewController.h"
#import "A3AppDelegate.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3SyncManager+mainmenu.h"
#import "A3UIDevice.h"

@interface A3SettingsRecentToKeepViewController () <UIActionSheetDelegate>

@end

@implementation A3SettingsRecentToKeepViewController

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSDictionary *recentMenus = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityRecentlyUsed];
	return recentMenus ? 2 : 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger maxMenus = [[A3SyncManager sharedSyncManager] maximumRecentlyUsedMenus];
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.accessoryType = maxMenus == 0 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 0;
				break;
			case 1:
				cell.accessoryType = maxMenus == 1 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 1;
				break;
			case 2:
				cell.accessoryType = maxMenus == 2 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 2;
				break;
			case 3:
				cell.accessoryType = maxMenus == 3 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 3;
				break;
			case 4:
				cell.accessoryType = maxMenus == 5 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 5;
				break;
		}
		cell.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Most Recent", @"StringsDict", nil), (long)cell.tag];
	} else if (indexPath.section == 1) {
		cell.textLabel.textColor = [[A3AppDelegate instance] themeColor];
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[[A3AppDelegate instance] storeMaximumNumberRecentlyUsedMenus:(NSUInteger) cell.tag];

		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:self];
		
		[tableView reloadData];
	}
	else if (indexPath.section == 1)
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self askClearUsedItems:cell];
	}
}

- (void)askClearUsedItems:(UITableViewCell *)cell {
#ifdef __IPHONE_8_0
    if (!IS_IOS7 && IS_IPAD) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Clear Recent", @"Clear Recent") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self clearRecentAction];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:NULL];
        }]];
        alertController.modalInPopover = UIModalPresentationPopover;
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        
        CGRect fromRect = [self.tableView convertRect:cell.bounds fromView:cell];
        fromRect.origin.x = self.view.center.x;
        fromRect.size = CGSizeZero;
        popover.sourceView = self.view;
        popover.sourceRect = fromRect;
        popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
        
        [self presentViewController:alertController animated:YES completion:NULL];
    }
    else
#endif
    {
        [self showClearRecentActionSheet];
    }
}

- (void)clearRecentAction {
    [[A3AppDelegate instance] clearRecentlyUsedMenus];
    [self.tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self setFirstActionSheet:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self setFirstActionSheet:nil];
    
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self clearRecentAction];
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
            [self showClearRecentActionSheet];
            break;
            
        default:
            break;
    }
}

- (void)showClearRecentActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"Clear Recent", @"Clear Recent")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    actionSheet.tag = 0;
    [self setFirstActionSheet:actionSheet];
}
@end
