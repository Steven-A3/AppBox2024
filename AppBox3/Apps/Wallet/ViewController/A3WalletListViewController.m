//
//  A3WalletListViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/29/14 10:57 AM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+A3Addition.h"
#import "A3WalletCategoryViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3WalletAllViewController.h"
#import "WalletCategory.h"
#import "WalletItem+Favorite.h"
#import "WalletData.h"
#import "A3WalletListBigPhotoCell.h"
#import "NSDate+TimeAgo.h"
#import "WalletItem+initialize.h"
#import "WalletFieldItem+initialize.h"
#import "WalletField+initialize.h"
#import "A3WalletListBigVideoCell.h"
#import "NSString+WalletStyle.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3WalletListPhotoCell.h"
#import "A3WalletItemViewController.h"
#import "A3WalletVideoItemViewController.h"
#import "A3WalletPhotoItemViewController.h"
#import "NSMutableArray+A3Sort.h"

NSString *const A3WalletTextCellID1 = @"A3WalletListTextCell";
NSString *const A3WalletBigVideoCellID1 = @"A3WalletListBigVideoCell";
NSString *const A3WalletBigPhotoCellID1 = @"A3WalletListBigPhotoCell";
NSString *const A3WalletTextCellID = @"A3WalletListTextCell";
NSString *const A3WalletPhotoCellID = @"A3WalletListPhotoCell";
NSString *const A3WalletAllTopCellID = @"A3WalletAllTopCell";
NSString *const A3WalletNormalCellID = @"A3WalletNormalCellID";
NSString *const A3WalletPhotoCellID2 = @"A3WalletListPhotoCell";

@implementation A3WalletListViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];

	[self makeBackButtonEmptyArrow];
	self.navigationItem.hidesBackButton = YES;

	[self leftBarButtonAppsButton];

	[self initializeViews];

	[self registerContentSizeCategoryDidChangeNotification];

	self.tabBarController.tabBar.translucent = NO;
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
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

- (void)contentSizeDidChange:(NSNotification *) notification
{
	[self.tableView reloadData];
}

- (void)initializeViews
{
	_tableView = [[FMMoveTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.rowHeight = 48.0;
	_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	_tableView.separatorColor = [self tableViewSeparatorColor];
	_tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.category.name isEqualToString:WalletCategoryTypePhoto] || [self.category.name isEqualToString:WalletCategoryTypeVideo]) {
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
	[self.view addSubview:_tableView];

	[_tableView registerClass:[A3WalletListBigVideoCell class] forCellReuseIdentifier:A3WalletBigVideoCellID1];
	[_tableView registerClass:[A3WalletListBigPhotoCell class] forCellReuseIdentifier:A3WalletBigPhotoCellID1];
	[_tableView registerClass:[A3WalletListPhotoCell class] forCellReuseIdentifier:A3WalletPhotoCellID];
	[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:A3WalletNormalCellID];
	[_tableView registerClass:[A3WalletListPhotoCell class] forCellReuseIdentifier:A3WalletPhotoCellID2];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	if (IS_IPAD) {
		[self showLeftNavigationBarItems];
	}
}

- (void)showLeftNavigationBarItems
{
    // 현재 more탭바인지 여부 체크
    if (self.isFromMoreTableViewController) {
        self.navigationItem.leftItemsSupplementBackButton = YES;
        // more 탭바

        self.navigationItem.hidesBackButton = NO;

        if (IS_IPAD) {
            if (IS_LANDSCAPE) {
                self.navigationItem.leftBarButtonItem = nil;
            }
            else {
				[self leftBarButtonAppsButton];
            }
        }
        else {
			[self leftBarButtonAppsButton];
        }
    } else {
		[self leftBarButtonAppsButton];
    }
}

- (UIButton *)addButton
{
	if (!_addButton) {
		_addButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_addButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
		_addButton.frame = CGRectMake(0, 0, 44, 44);
		[_addButton addTarget:self action:@selector(addWalletItemAction) forControlEvents:UIControlEventTouchUpInside];
	}

	return _addButton;
}

- (void)addButtonConstraints
{
    CGFloat fromBottom = 33;

	[_addButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.centerY.equalTo(self.view.bottom).with.offset(-fromBottom);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// This class is a wrapper class for Wallet List View Controllers and each sub classes
	// MUST implement this member for its own.
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath walletItem:(WalletItem *)item {
	UITableViewCell *cell;
	if ([_category.name isEqualToString:WalletCategoryTypePhoto]) {
		A3WalletListBigPhotoCell *photoCell;
		photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletBigPhotoCellID1 forIndexPath:indexPath];

		photoCell.rightLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		photoCell.rightLabel.text = [item.modificationDate timeAgo];
		if (IS_IPHONE) {
			photoCell.rightLabel.font = [UIFont systemFontOfSize:12];
		}
		else {
			photoCell.rightLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		}

		NSMutableArray *photoPick = [[NSMutableArray alloc] init];
		NSArray *fieldItems = [item fieldItemsArray];
		for (int i=0; i<fieldItems.count; i++) {
			WalletFieldItem *fieldItem = fieldItems[i];
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] && fieldItem.image) {
				[photoPick addObject:fieldItem];
			}
		}

		int maxPhotoCount = (IS_IPAD) ? 5 : 2;
		int showPhotoCount = MIN(maxPhotoCount, (int)photoPick.count);

		[photoCell resetThumbImages];

		for (int i=0; i<showPhotoCount; i++) {
			WalletFieldItem *fieldItem = photoPick[i];
			[photoCell addThumbImage:fieldItem.thumbnailImage];
		}

		cell = photoCell;
	}
	else if ([_category.name isEqualToString:WalletCategoryTypeVideo]) {
		A3WalletListBigVideoCell *videoCell;
		videoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletBigVideoCellID1 forIndexPath:indexPath];

		videoCell.rightLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		videoCell.rightLabel.text = [item.modificationDate timeAgo];
		if (IS_IPHONE) {
			videoCell.rightLabel.font = [UIFont systemFontOfSize:12];
		}
		else {
			videoCell.rightLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		}

		NSMutableArray *photoPick = [[NSMutableArray alloc] init];
		NSArray *fieldItems = [item fieldItemsArray];
		for (int i=0; i<fieldItems.count; i++) {
			WalletFieldItem *fieldItem = fieldItems[i];
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo] && fieldItem.video) {
				[photoPick addObject:fieldItem];
			}
		}

		int maxPhotoCount = (IS_IPAD) ? 5 : 2;
		int showPhotoCount = MIN(maxPhotoCount, (int)photoPick.count);

		[videoCell resetThumbImages];
		for (int i=0; i<showPhotoCount; i++) {
			WalletFieldItem *fieldItem = photoPick[i];
			UIImage *thumbImg = [UIImage imageWithContentsOfFile:[fieldItem videoThumbnailPathInOriginal:YES ]];
			float duration = [WalletData getDurationOfMovie:[fieldItem videoFileURLInOriginal:YES ]];
			[videoCell addThumbImage:thumbImg withDuration:duration];
		}

		cell = videoCell;
	} else if ([item.category.name isEqualToString:WalletCategoryTypePhoto]) {
		A3WalletListPhotoCell *photoCell;
		photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletPhotoCellID forIndexPath:indexPath];

		NSMutableArray *photoPick = [[NSMutableArray alloc] init];
		NSArray *fieldItems = [item fieldItemsArray];
		for (int i=0; i<fieldItems.count; i++) {
			WalletFieldItem *fieldItem = fieldItems[i];
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] && fieldItem.image) {
				[photoPick addObject:fieldItem];
			}
		}

		NSInteger maxPhotoCount = (IS_IPAD) ? 5 : 2;
		NSInteger showPhotoCount = MIN(maxPhotoCount, photoPick.count);

		[photoCell resetThumbImages];

		for (NSUInteger idx = 0; idx < showPhotoCount; idx++) {
			WalletFieldItem *fieldItem = photoPick[idx];
			UIImage *thumbImg = [fieldItem thumbnailImage];

			[photoCell addThumbImage:thumbImg isVideo:NO ];
		}

		cell = photoCell;
	}
	else if ([item.category.name isEqualToString:WalletCategoryTypeVideo]) {
		A3WalletListPhotoCell *videoCell;
		videoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletPhotoCellID forIndexPath:indexPath];

		NSMutableArray *photoPick = [[NSMutableArray alloc] init];
		NSArray *fieldItems = [item fieldItemsArray];
		for (NSUInteger idx = 0; idx < fieldItems.count; idx++) {
			WalletFieldItem *fieldItem = fieldItems[idx];
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo] && fieldItem.video) {
				[photoPick addObject:fieldItem];
			}
		}

		NSInteger maxPhotoCount = (IS_IPAD) ? 5 : 2;
		NSInteger showPhotoCount = MIN(maxPhotoCount, photoPick.count);

		[videoCell resetThumbImages];
		for (NSUInteger idx =0; idx < showPhotoCount; idx++) {
			WalletFieldItem *fieldItem = photoPick[idx];
			UIImage *thumbImg = [UIImage imageWithContentsOfFile:[fieldItem videoThumbnailPathInOriginal:YES ]];
			[videoCell addThumbImage:thumbImg isVideo:YES ];
		}

		cell = videoCell;
	}
	else {
		UITableViewCell *dataCell;
		dataCell = [tableView dequeueReusableCellWithIdentifier:A3WalletTextCellID];
		if (dataCell == nil) {
			dataCell = [[UITableViewCell alloc] initWithStyle:IS_IPAD ? UITableViewCellStyleValue1:UITableViewCellStyleSubtitle reuseIdentifier:A3WalletTextCellID];
			dataCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			dataCell.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		}
		if (IS_IPHONE) {
			dataCell.textLabel.font = [UIFont systemFontOfSize:15];
			dataCell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		}
		else {
			dataCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
			dataCell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		}

		if (item.name && item.name.length > 0) {
			dataCell.textLabel.text = item.name;
		}
		else {
			dataCell.textLabel.text = NSLocalizedString(@"New Item", @"New Item");
		}

		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
		NSArray *fieldItems = [item.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
		if (fieldItems.count > 0) {
			WalletFieldItem *fieldItem = fieldItems[0];
			NSString *itemValue = @"";
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
				NSDateFormatter *df = [[NSDateFormatter alloc] init];
				[df setDateStyle:NSDateFormatterFullStyle];
				itemValue = [df stringFromDate:fieldItem.date];
			}
			else {
				itemValue = fieldItem.value;
			}

			if (itemValue && (itemValue.length>0)) {
				NSString *styleValue = [itemValue stringForStyle:fieldItem.field.style];
				dataCell.detailTextLabel.text = styleValue;
			}
			else {
				dataCell.detailTextLabel.text = @"";
			}
		}
		else {
			dataCell.detailTextLabel.text = @"";
		}

		cell = dataCell;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withItem:(WalletItem *)item {
	if ([item.category.name isEqualToString:WalletCategoryTypePhoto]) {
		NSString *boardName = @"WalletPhoneStoryBoard";
		UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
		A3WalletPhotoItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletPhotoItemViewController"];
		viewController.hidesBottomBarWhenPushed = YES;
		viewController.item = item;
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else if ([item.category.name isEqualToString:WalletCategoryTypeVideo]) {
		NSString *boardName = @"WalletPhoneStoryBoard";
		UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
		A3WalletVideoItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletVideoItemViewController"];
		viewController.hidesBottomBarWhenPushed = YES;
		viewController.item = item;
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else {
		UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
		A3WalletItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemViewController"];
		viewController.hidesBottomBarWhenPushed = YES;
		viewController.item = item;
		viewController.showCategory = _showCategoryInDetailViewController;
		[self.navigationController pushViewController:viewController animated:YES];
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	[self.items moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self.items moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
