//
//  A3WalletCategoryViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCategoryViewController.h"
#import "A3WalletCategoryInfoViewController.h"
#import "A3WalletListBigVideoCell.h"
#import "A3WalletListBigPhotoCell.h"
#import "WalletData.h"
#import "WalletItem.h"
#import "WalletFieldItem.h"
#import "WalletFieldItem+initialize.h"
#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "NSString+WalletStyle.h"
#import "NSMutableArray+A3Sort.h"
#import "A3WalletItemEditViewController.h"
#import "UIColor+A3Addition.h"
#import "A3InstructionViewController.h"
#import "WalletItem+initialize.h"
#import "A3UserDefaults.h"
#import "WalletCategory.h"
#import "WalletField.h"
#import "NSString+conversion.h"
#import "A3WalletListPhotoCell.h"

@interface A3WalletCategoryViewController () <UIActionSheetDelegate, UIActivityItemSource, UIPopoverControllerDelegate, FMMoveTableViewDelegate, FMMoveTableViewDataSource, A3InstructionViewControllerDelegate, NSFileManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIBarButtonItem *deleteBarItem;
@property (nonatomic, strong) UIBarButtonItem *shareBarItem;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) NSMutableArray *shareTextList;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, strong) UILocalizedIndexedCollation *collation;
@property (nonatomic, strong) NSMutableArray *sectionsArray;
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;
@property (nonatomic, strong) NSArray *filteredResults;

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIBarButtonItem *searchItem;

@end

@implementation A3WalletCategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPAD) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.category.name style:UIBarButtonItemStylePlain target:nil action:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
        self.navigationItem.rightBarButtonItems = @[self.searchItem, [[UIBarButtonItem alloc] initWithCustomView:self.infoButton], [self instructionHelpBarButton]];
    }
    else {
        [self makeBackButtonEmptyArrow];
        self.navigationItem.rightBarButtonItems = @[self.searchItem, [[UIBarButtonItem alloc] initWithCustomView:self.infoButton]];
    }

    [self.view addSubview:self.searchBar];
    [self mySearchDisplayController];

    [self setupInstructionView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
    
// TODO
// 카테코리 테이블에서 임시로 순서변경 제스쳐 제거.
    for (UIGestureRecognizer *gesture in [self.tableView gestureRecognizers]) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [self.tableView removeGestureRecognizer:gesture];
        }
    }
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    [self.searchBar removeFromSuperview];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)cleanUp {
	[self dismissInstructionViewController:nil];
	[self removeObserver];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)mainMenuDidShow {
	[self enableControls:NO];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
	[self.addButton setEnabled:enable];
	self.tabBarController.tabBar.selectedImageTintColor = enable ? nil : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.view addSubview:self.searchBar];

    // 테이블 항목을 선택시에는 카테고리 이름이 backBar Item 이 되고,나머지는 공백.
    // viewWillAppear 에서 공백으로 초기화해줌 (테이블 항목 선택시, 타이틀을 카테고리 이름으로 함)

	[self showLeftNavigationBarItems];

    // 항목 갱신
    [self refreshItems];

	// 타이틀 표시 (갯수가 있으므로 페이지 진입시 갱신한다.)
	self.navigationItem.title = [NSString stringWithFormat:@"%@(%ld)", self.category.name, (long)self.items.count];

    // more button 활성화여부
    [self itemCountCheck];
}

- (void)cloudStoreDidImport {
	self.items = nil;
	[self refreshItems];

	// 타이틀 표시 (갯수가 있으므로 페이지 진입시 갱신한다.)
	self.navigationItem.title = [NSString stringWithFormat:@"%@(%ld)", self.category.name, (long)self.items.count];

	// more button 활성화여부
	[self itemCountCheck];
}

- (void)initializeViews
{
	[super initializeViews];

    [self.view addSubview:self.addButton];
    [self addButtonConstraints];

    [self.tableView registerClass:[A3WalletListBigVideoCell class] forCellReuseIdentifier:A3WalletBigVideoCellID1];
    [self.tableView registerClass:[A3WalletListBigPhotoCell class] forCellReuseIdentifier:A3WalletBigPhotoCellID1];
}

- (void)itemCountCheck
{
    BOOL itemHave = (self.items.count>0) ? YES:NO;
    self.editButtonItem.enabled = itemHave;
}

- (NSMutableArray *)items
{
    if (!super.items) {
		FNLOG();
		NSMutableArray *items;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", self.category.uniqueID];
//        items = [NSMutableArray arrayWithArray:[WalletItem MR_findAllSortedBy:@"order" ascending:YES withPredicate:predicate]];
        items = [NSMutableArray arrayWithArray:[WalletItem MR_findAllSortedBy:@"name" ascending:YES withPredicate:predicate]];
		[super setItems:items];
    }

    return super.items;
}

- (UIBarButtonItem *)deleteBarItem
{
    if (!_deleteBarItem) {
        _deleteBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete01"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteItemAction:)];
    }

    return _deleteBarItem;
}

- (UIBarButtonItem *)shareBarItem
{
    if (!_shareBarItem) {
        _shareBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareItemAction:)];
    }

    return _shareBarItem;
}

- (NSArray *)rightBarItems
{
    self.infoButton.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithCustomView:self.infoButton];

    return @[self.editButtonItem, info];
}

- (NSArray *)toolItems
{
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    return @[self.deleteBarItem, flexible, self.shareBarItem];
}

- (UIButton *)infoButton
{
    if (!_infoButton) {
        _infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_infoButton setImage:[UIImage imageNamed:@"information"] forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		_infoButton.bounds = CGRectMake(0, 0, 30, 40);
    }

    return _infoButton;
}

- (A3WalletCategoryInfoViewController *)cateInfoViewController
{
    A3WalletCategoryInfoViewController *viewController = [[A3WalletCategoryInfoViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.category = self.category;
    return viewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareButtonAction:(id)sender {
    [self shareAll:sender];
}

- (void)infoButtonAction:(id)sender {
	[self.navigationController pushViewController:[self cateInfoViewController] animated:YES];
}

- (void)editCancelAction:(id)sender {
    [self setEditing:NO animated:YES];
}

- (void)editDoneAction:(id)sender {
    [self setEditing:NO animated:YES];
}

- (void)deleteAllAction:(id)sender {
    // delete all items
    if (self.tableView.editing == NO) {
        return;
    }

    if (self.items.count > 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   destructiveButtonTitle:NSLocalizedString(@"Delete All", @"Delete All")
                                                        otherButtonTitles:nil];
        actionSheet.tag = 1111;
        [actionSheet showInView:self.view];
    }
}

- (void)deleteItemAction:(id)sender {
    // 선택된 walletItem 삭제하기
    if (self.tableView.editing == NO) {
        return;
    }

    NSArray *ips = [self.tableView indexPathsForSelectedRows];

    if (ips.count > 0) {

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                   destructiveButtonTitle:NSLocalizedString(@"Delete Items", @"Delete Items")
                                                        otherButtonTitles:nil];
        actionSheet.tag = 2222;
        [actionSheet showInView:self.view];
    }
}

- (void)shareItemAction:(id)sender {
	if (self.editing == NO) {
		return;
	}

	self.shareTextList = [NSMutableArray new];

	NSArray *ips = [self.tableView indexPathsForSelectedRows];

	for (NSInteger index = 0; index < ips.count; index++) {
		NSIndexPath *ip = ips[index];
        NSArray *section = self.sectionsArray[ip.section];
		if ([section[ip.row] isKindOfClass:[WalletItem class]]) {

			WalletItem *item = section[ip.row];
			NSString *convertInfoText = @"";

			if ([self.category.uniqueID isEqualToString:A3WalletUUIDPhotoCategory]) {
				NSString *itemName = item.name;
				NSString *firstFieldItemValue = NSLocalizedString(@"Photo", @"Photo");

				convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
			}
			else if ([self.category.uniqueID isEqualToString:A3WalletUUIDVideoCategory]) {
				NSString *itemName = item.name;
				NSString *firstFieldItemValue = NSLocalizedString(@"Video", @"Video");

				convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
			}
			else {
				NSString *itemName = item.name;
				NSString *firstFieldItemValue = @"";

				NSArray *fieldItems = [item fieldItemsArraySortedByFieldOrder];
				if (fieldItems.count>0) {
					WalletFieldItem *fieldItem = fieldItems[0];
					NSString *itemValue;

					WalletField *field = [WalletData fieldOfFieldItem:fieldItem];
					if ([field.type isEqualToString:WalletFieldTypeDate]) {
						NSDateFormatter *df = [[NSDateFormatter alloc] init];
						[df setDateStyle:NSDateFormatterFullStyle];
						itemValue = [df stringFromDate:fieldItem.date];
					}
					else {
						itemValue = fieldItem.value;
					}

					if (itemValue && (itemValue.length>0)) {
						firstFieldItemValue = [itemValue stringForStyle:field.style];
					}
				}

				convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
			}

			[_shareTextList addObject:convertInfoText];
		}
	}

	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
	[activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
		FNLOG(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);

		[self editCancelAction:nil];
	}];

	[activityController setValue:@"My Subject Text" forKey:@"subject"];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
		[popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		_sharePopoverController = popoverController;
		_sharePopoverController.delegate = self;
	}

	/*
	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender];
	if (IS_IPAD) {
		_sharePopoverController.delegate = self;
	}
	 */
}

- (void)shareAll:(id)sender {
	self.shareTextList = [NSMutableArray new];

	for (NSUInteger index = 0; index < self.items.count; index++) {
		if ([self.items[index] isKindOfClass:[WalletItem class]]) {

			WalletItem *item = self.items[index];
			NSString *convertInfoText = @"";

			if ([self.category.uniqueID isEqualToString:A3WalletUUIDPhotoCategory]) {
				NSString *itemName = item.name;
				NSString *firstFieldItemValue = NSLocalizedString(@"Photo", @"Photo");

				convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
			}
			else if ([self.category.uniqueID isEqualToString:A3WalletUUIDVideoCategory]) {
				NSString *itemName = item.name;
				NSString *firstFieldItemValue = @"Video";

				convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
			}
			else {

				NSString *itemName = item.name;
				NSString *firstFieldItemValue = @"";

				NSArray *fieldItems = [item fieldItemsArraySortedByFieldOrder];
				if (fieldItems.count>0) {
					WalletFieldItem *fieldItem = fieldItems[0];
					NSString *itemValue = @"";
					WalletField *field = [WalletData fieldOfFieldItem:fieldItem];
					if ([field.type isEqualToString:WalletFieldTypeDate]) {
						NSDateFormatter *df = [[NSDateFormatter alloc] init];
						[df setDateStyle:NSDateFormatterFullStyle];
						itemValue = [df stringFromDate:fieldItem.date];
					}
					else {
						itemValue = fieldItem.value;
					}

					if (itemValue && (itemValue.length>0)) {
						firstFieldItemValue = [itemValue stringForStyle:field.style];
					}
				}

				convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
			}

			[_shareTextList addObject:convertInfoText];
		}
	}

	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
	[activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
		FNLOG(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);

		[self editCancelAction:nil];
	}];

	[activityController setValue:@"My Subject Text" forKey:@"subject"];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
		[popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		_sharePopoverController = popoverController;
		_sharePopoverController.delegate = self;
	}
}

- (A3WalletItemEditViewController *)itemEditViewController
{
	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletItemEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemEditViewController"];
	viewController.isAddNewItem = YES;
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.category = self.category;

    return viewController;
}

- (void)addWalletItemAction {
	A3WalletItemEditViewController *viewController = [self itemEditViewController];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:nav animated:YES completion:NULL];
}

- (void)refreshItems
{
    self.items = nil;
    [self configureSections];
    [self.tableView reloadData];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForWalletCategoryView = @"A3V3InstructionDidShowForWalletCategoryView";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForWalletCategoryView]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForWalletCategoryView];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard     instantiateViewControllerWithIdentifier:@"Wallet_2"];
    self.instructionViewController.delegate = self;
    [self.tabBarController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.tabBarController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - Search relative

- (UIBarButtonItem *)searchItem {
    if (!_searchItem) {
        _searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonAction:)];
    }
    return _searchItem;
}

- (void)searchButtonAction:(id)sender
{
    [self.searchBar becomeFirstResponder];
}

- (UISearchDisplayController *)mySearchDisplayController {
    if (!_mySearchDisplayController) {
        _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _mySearchDisplayController.delegate = self;
        _mySearchDisplayController.searchBar.delegate = self;
        _mySearchDisplayController.searchResultsTableView.delegate = self;
        _mySearchDisplayController.searchResultsTableView.dataSource = self;
        _mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        _mySearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
        _mySearchDisplayController.searchResultsTableView.rowHeight = 48;

		UITableView *searchResultTableView = _mySearchDisplayController.searchResultsTableView;
		[searchResultTableView registerClass:[A3WalletListBigVideoCell class] forCellReuseIdentifier:A3WalletBigVideoCellID1];
		[searchResultTableView registerClass:[A3WalletListBigPhotoCell class] forCellReuseIdentifier:A3WalletBigPhotoCellID1];
		[searchResultTableView registerClass:[A3WalletListPhotoCell class] forCellReuseIdentifier:A3WalletPhotoCellID];
		[searchResultTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:A3WalletNormalCellID];
    }
    return _mySearchDisplayController;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, kSearchBarHeight)];
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    FNLOG();
    NSPredicate *predicate;
    if (searchText && searchText.length) {
        predicate = [NSPredicate predicateWithFormat:@"categoryID == %@ AND name contains[cd] %@", self.category.uniqueID, searchText];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", self.category.uniqueID];
    }
    self.items = [NSMutableArray arrayWithArray:[WalletItem MR_findAllSortedBy:@"name" ascending:YES withPredicate:predicate]];
    [self configureSections];
    [self.tableView reloadData];
}

#pragma mark- UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [self.tableView setHidden:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    [self.tableView setHidden:NO];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {

}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {

}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    CGRect frame = _searchBar.frame;
    frame.origin.y = 20.0;
    _searchBar.frame = frame;

    frame = self.tableView.frame;
    frame.origin.y += 20.0;
    self.tableView.frame = frame;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    CGRect frame = _searchBar.frame;
    frame.origin.y = 0.0;
    _searchBar.frame = frame;

    frame = self.tableView.frame;
    frame.origin.y -= 20.0;
    self.tableView.frame = frame;
}

#pragma mark - SearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearchText:searchText];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self filterContentForSearchText:nil];
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - PopOverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{

}

#pragma mark - UIActivityItemSource

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return @"Wallet in the AppBox Pro";
    }

    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        NSMutableString *txt = [NSMutableString new];
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"<br/>"];
        }
        return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share an information with you.", @"I'd like to share a information with you.")
									   contents:txt
										   tail:NSLocalizedString(@"You can manage your information in the AppBox Pro.", nil)];
    }
    else {
        NSMutableString *txt = [NSMutableString new];
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"\n"];
        }
		[txt appendString:@"\n"];
		[txt appendString:NSLocalizedString(@"Check out the AppBox Pro!", nil)];

        return txt;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return NSLocalizedString(@"Share information", nil);
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (actionSheet.tag == 1111) {
        // delete all
        if (buttonIndex == actionSheet.destructiveButtonIndex) {

            for (NSInteger idx = self.items.count-1; idx >= 0; idx--) {
                if ([self.items[idx] isKindOfClass:[WalletItem class]]) {

                    WalletItem *item = self.items[idx];
                    [self.items removeObject:item];
					[item deleteWalletItemInContext:nil];
				}
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            [self.tableView reloadData];

            self.deleteBarItem.enabled = NO;
            self.shareBarItem.enabled = NO;

            // 자동으로 edit 화면을 나간다.
            [self editDoneAction:nil];
        }
    }
    else if (actionSheet.tag == 2222) {
        NSArray *ips = [self.tableView indexPathsForSelectedRows];

        if (ips.count > 0) {

            NSMutableIndexSet *mis = [NSMutableIndexSet new];
            for (int i=0; i<ips.count; i++) {
                NSIndexPath *indexPath = ips[i];
                [mis addIndex:indexPath.row];

                NSArray *section = self.sectionsArray[indexPath.section];
                if ([section[indexPath.row] isKindOfClass:[WalletItem class]]) {

                    WalletItem *item = section[indexPath.row];
					[item deleteWalletItemInContext:nil];
				}
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [self.items removeObjectsAtIndexes:mis];

            [self.tableView deleteRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationFade];

            // 만약 남아있는 _items 이 없다면 edit 화면을 나간다.
            if (self.items.count == 0) {
                [self editDoneAction:nil];
            }
        }
    }
}

#pragma mark - WalletItemAddDelegate
- (void)walletItemAddCompleted:(WalletItem *)addedItem
{
    [self refreshItems];
}

- (void)walletITemAddCanceled
{

}

- (UILocalizedIndexedCollation *)collation {
    if (!_collation) {
        [self configureSections];
    }
    return _collation;
}

- (void)configureSections {
    // Get the current collation and keep a reference to it.
    _collation = [UILocalizedIndexedCollation currentCollation];

    NSInteger index, sectionTitlesCount = [[self.collation sectionTitles] count];

    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];

    // Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
    for (index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }

    // Segregate the time zones into the appropriate arrays.
    for (id object in self.items) {

        // Ask the collation which section number the time zone belongs in, based on its locale name.
        NSInteger sectionNumber = [self.collation sectionForObject:object collationStringSelector:NSSelectorFromString(@"name")];

        // Get the array for the section.
        NSMutableArray *sections = newSectionsArray[sectionNumber];

        //  Add the time zone to the section.
        [sections addObject:object];
    }

    NSMutableArray *dataContainingSectionsArray = [NSMutableArray new];
    NSMutableArray *sectionTitles = [NSMutableArray new];
    NSMutableArray *sectionIndexTitles = [NSMutableArray new];

    // Now that all the data's in place, each section array needs to be sorted.
    for (index = 0; index < sectionTitlesCount; index++) {

        NSMutableArray *dataArrayForSection = newSectionsArray[index];

        if ([dataArrayForSection count]) {
            // If the table view or its contents were editable, you would make a mutable copy here.
            NSArray *sortedDataArrayForSection = [self.collation sortedArrayFromArray:dataArrayForSection collationStringSelector:NSSelectorFromString(@"name")];

            WalletItem *firstItem = sortedDataArrayForSection[0];
            NSString *firstLetter = [[[firstItem name] substringToIndex:1] componentsSeparatedByKorean];
            [dataContainingSectionsArray addObject:sortedDataArrayForSection];
            NSInteger sectionTitleIndex = [[_collation sectionTitles] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [obj isEqualToString:firstLetter];
            }];
            if (sectionTitleIndex != NSNotFound) {
                [sectionTitles addObject:[_collation sectionTitles][sectionTitleIndex]];
                [sectionIndexTitles addObject:[_collation sectionTitles][sectionTitleIndex]];
            } else {
                [sectionTitles addObject:[_collation sectionTitles][index]];
                [sectionIndexTitles addObject:[_collation sectionTitles][index]];
            }
        }
    }

    self.sectionsArray = dataContainingSectionsArray;
    self.sectionTitles = sectionTitles;
    self.sectionIndexTitles = sectionIndexTitles;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        NSArray *selectedItems = [tableView indexPathsForSelectedRows];

        if (selectedItems.count == 0) {
            self.deleteBarItem.enabled = NO;
            self.shareBarItem.enabled = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        self.shareBarItem.enabled = YES;
        self.deleteBarItem.enabled = YES;
        return;
    }

    NSArray *section = self.sectionsArray[indexPath.section];
	[super tableView:tableView didSelectRowAtIndexPath:indexPath withItem:section[indexPath.row]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowsInSection = (self.sectionsArray)[section];
    return [rowsInSection count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 28;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
		UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *) view;
		headerView.textLabel.font = [UIFont fontWithName:headerView.textLabel.font.fontName size:17];
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.category.uniqueID isEqualToString:A3WalletUUIDPhotoCategory] || [self.category.uniqueID isEqualToString:A3WalletUUIDVideoCategory]) {
        return 84;
    }
    else {
        return 48;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self.items objectAtIndex:indexPath.row] isKindOfClass:[WalletItem class]]) {

        NSArray *section = self.sectionsArray[indexPath.section];
		WalletItem *item = section[indexPath.row];
		return [self tableView:tableView cellForRowAtIndexPath:indexPath walletItem:item];
	}
	return nil;
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

        NSArray *section = self.sectionsArray[indexPath.section];
        if ([section[indexPath.row] isKindOfClass:[WalletItem class]]) {
            WalletItem *item = section[indexPath.row];
			NSArray *fieldItems = [item fieldItemsArraySortedByFieldOrder];
			[fieldItems enumerateObjectsUsingBlock:^(WalletFieldItem *fieldItem, NSUInteger idx, BOOL *stop) {
				BOOL result;
				NSFileManager *fileManager = [[NSFileManager alloc] init];
				fileManager.delegate = self;
				if ([fieldItem.hasImage boolValue]) {
					if ([fileManager fileExistsAtPath:[fieldItem photoImageThumbnailPathInOriginal:NO]]) {
						result = [fileManager removeItemAtPath:[fieldItem photoImageThumbnailPathInOriginal:NO] error:NULL];
						NSAssert(result, @"result");
					}
					if ([fileManager fileExistsAtPath:[fieldItem photoImageThumbnailPathInOriginal:YES]]) {
						result = [fileManager removeItemAtPath:[fieldItem photoImageThumbnailPathInOriginal:YES] error:NULL];
						NSAssert(result, @"result");
					}
					if ([fileManager fileExistsAtPath:[[fieldItem photoImageURLInOriginalDirectory:NO] path]]) {
						result = [fileManager removeItemAtURL:[fieldItem photoImageURLInOriginalDirectory:NO] error:NULL];
						NSAssert(result, @"result");
					}
					if ([fileManager fileExistsAtPath:[[fieldItem photoImageURLInOriginalDirectory:YES] path]]) {
						[fileManager removeItemAtPath:[[fieldItem photoImageURLInOriginalDirectory:YES] path] error:NULL];
						NSAssert(result, @"result");
					}
				} else {
					if ([fileManager fileExistsAtPath:[fieldItem videoThumbnailPathInOriginal:NO]]) {
						result = [fileManager removeItemAtPath:[fieldItem videoThumbnailPathInOriginal:NO] error:NULL];
						NSAssert(result, @"result");
					}
					if ([fileManager fileExistsAtPath:[[fieldItem videoFileURLInOriginal:YES] path]]) {
						result = [fileManager removeItemAtURL:[fieldItem videoFileURLInOriginal:YES] error:NULL];
						NSAssert(result, @"result");
					}
				}
			}];

            [item deleteWalletItemInContext:nil];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

            self.items = nil;
            [self configureSections];

            if ([section count] == 1) {
                [tableView reloadData];
            } else {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }

            // more button 활성화여부
            [self itemCountCheck];

            // 타이틀 표시 (갯수가 있으므로 페이지 진입시 갱신한다.)
            NSString *cateTitle = [NSString stringWithFormat:@"%@(%ld)", self.category.name, (long)self.items.count];
            self.navigationItem.title = cateTitle;
        }
    }
}

#pragma mark FileManagerDelegate

/* fileManager:shouldCopyItemAtPath:toPath: gives the delegate an opportunity to filter the resulting copy. Returning YES from this method will allow the copy to happen. Returning NO from this method causes the item in question to be skipped. If the item skipped was a directory, no children of that directory will be copied, nor will the delegate be notified of those children.
 
 If the delegate does not implement this method, the NSFileManager instance acts as if this method returned YES.
 */
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldCopyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
//    
//}
//
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldCopyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
//    
//}

/* fileManager:shouldProceedAfterError:copyingItemAtPath:toPath: gives the delegate an opportunity to recover from or continue copying after an error. If an error occurs, the error object will contain an NSError indicating the problem. The source path and destination paths are also provided. If this method returns YES, the NSFileManager instance will continue as if the error had not occurred. If this method returns NO, the NSFileManager instance will stop copying, return NO from copyItemAtPath:toPath:error: and the error will be provied there.
 
 If the delegate does not implement this method, the NSFileManager instance acts as if this method returned NO.
 */
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
//    
//}
//
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
//    
//}

/* fileManager:shouldMoveItemAtPath:toPath: gives the delegate an opportunity to not move the item at the specified path. If the source path and the destination path are not on the same device, a copy is performed to the destination path and the original is removed. If the copy does not succeed, an error is returned and the incomplete copy is removed, leaving the original in place.
 
 If the delegate does not implement this method, the NSFileManager instance acts as if this method returned YES.
 */
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldMoveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
//    
//}
//
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldMoveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
//    
//}

/* fileManager:shouldProceedAfterError:movingItemAtPath:toPath: functions much like fileManager:shouldProceedAfterError:copyingItemAtPath:toPath: above. The delegate has the opportunity to remedy the error condition and allow the move to continue.
 
 If the delegate does not implement this method, the NSFileManager instance acts as if this method returned NO.
 */
- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    FNLOG(@"Error : %@", error);
    return NO;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
    FNLOG(@"Error : %@", error);
    return NO;
}

/* fileManager:shouldLinkItemAtPath:toPath: acts as the other "should" methods, but this applies to the file manager creating hard links to the files in question.
 
 If the delegate does not implement this method, the NSFileManager instance acts as if this method returned YES.
 */
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldLinkItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
//    
//}
//
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldLinkItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
//    
//}

/* fileManager:shouldProceedAfterError:linkingItemAtPath:toPath: allows the delegate an opportunity to remedy the error which occurred in linking srcPath to dstPath. If the delegate returns YES from this method, the linking will continue. If the delegate returns NO from this method, the linking operation will stop and the error will be returned via linkItemAtPath:toPath:error:.
 
 If the delegate does not implement this method, the NSFileManager instance acts as if this method returned NO.
 */
- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error linkingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    FNLOG(@"Error : %@", error);
    return NO;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error linkingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
    FNLOG(@"Error : %@", error);
    return NO;
}

/* fileManager:shouldRemoveItemAtPath: allows the delegate the opportunity to not remove the item at path. If the delegate returns YES from this method, the NSFileManager instance will attempt to remove the item. If the delegate returns NO from this method, the remove skips the item. If the item is a directory, no children of that item will be visited.
 
 If the delegate does not implement this method, the NSFileManager instance acts as if this method returned YES.
 */
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path {
//    
//}
//
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtURL:(NSURL *)URL  {
//    
//}

/* fileManager:shouldProceedAfterError:removingItemAtPath: allows the delegate an opportunity to remedy the error which occurred in removing the item at the path provided. If the delegate returns YES from this method, the removal operation will continue. If the delegate returns NO from this method, the removal operation will stop and the error will be returned via linkItemAtPath:toPath:error:.
 
 If the delegate does not implement this method, the NSFileManager instance acts as if this method returned NO.
 */
- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtPath:(NSString *)path {
    FNLOG(@"Error : %@", error);
    return NO;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtURL:(NSURL *)URL {
    FNLOG(@"Error : %@", error);
    return NO;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
