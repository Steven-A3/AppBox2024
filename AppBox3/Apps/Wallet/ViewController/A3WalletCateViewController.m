//
//  A3WalletCateViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCateViewController.h"
#import "A3WalletCateInfoViewController.h"
#import "A3WalletAddItemViewController.h"
#import "A3WalletItemViewController.h"
#import "A3WalletPhotoItemViewController.h"
#import "A3WalletListBigVideoCell.h"
#import "A3WalletListBigPhotoCell.h"
#import "WalletData.h"
#import "WalletItem.h"
#import "WalletField.h"
#import "WalletFieldItem.h"
#import "WalletCategory.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+A3Addition.h"
#import "NSDate+TimeAgo.h"
#import "NSString+WalletStyle.h"
#import "WalletItem+initialize.h"
#import "A3WalletVideoItemViewController.h"
#import "NSMutableArray+A3Sort.h"


@interface A3WalletCateViewController () <WalletItemAddDelegate, UIActionSheetDelegate, UIActivityItemSource, UIPopoverControllerDelegate>
{
    BOOL		_isShowMoreMenu;
}

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIBarButtonItem *deleteBarItem;
@property (nonatomic, strong) UIBarButtonItem *shareBarItem;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) NSMutableArray *shareTextList;

@end

@implementation A3WalletCateViewController

NSString *const A3WalletTextCellID1 = @"A3WalletListTextCell";
NSString *const A3WalletBigVideoCellID1 = @"A3WalletListBigVideoCell";
NSString *const A3WalletBigPhotoCellID1 = @"A3WalletListBigPhotoCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self makeBackButtonEmptyArrow];

    self.navigationItem.rightBarButtonItems = [self rightBarItems];
    
    [self initializeViews];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
    
	if (IS_IPAD) {
        
        if (self.editing) {
            
        }
        else {
			[self showLeftNavigationBarItems];
        }
	}
    
    if (self.editing) {
        float tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        CGRect rect = self.tabBarController.view.frame;
        if (IS_IPHONE) {
            rect.size.height = [UIScreen mainScreen].bounds.size.height + tabBarHeight;
        }
        else {
            if (IS_LANDSCAPE) {
                rect.size.height = [UIScreen mainScreen].bounds.size.width + tabBarHeight;
            }
            else {
                rect.size.height = [UIScreen mainScreen].bounds.size.height + tabBarHeight;
            }
        }
        self.tabBarController.view.frame = rect;
    }
    else {
        CGRect rect = self.tabBarController.view.frame;
        if (IS_IPHONE) {
            rect.size.height = [UIScreen mainScreen].bounds.size.height;
        }
        else {
            if (IS_LANDSCAPE) {
                rect.size.height = [UIScreen mainScreen].bounds.size.width;
            }
            else {
                rect.size.height = [UIScreen mainScreen].bounds.size.height;
            }
        }
        self.tabBarController.view.frame = rect;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 테이블 항목을 선택시에는 카테고리 이름이 backBar Item이 되고,나머지는 공백.
    // viewwillAppear에서 공백으로 초기화해줌 (테이블 항목 선택시, 타이틀을 카테고리 이름으로 함)

	[self showLeftNavigationBarItems];
    
    // 항목 갱신
    [self refreshItems];
    
    // 타이틀 표시 (갯수가 있으므로 페이지 진입시 갱신한다.)
    NSString *cateTitle = [NSString stringWithFormat:@"%@(%d)", _category.name, (int)_items.count];
    self.navigationItem.title = cateTitle;
    
    // more button 활성화여부
    [self itemCountCheck];
}

- (void)initializeViews
{
    self.tableView = [UITableView new];
	_tableView.frame = self.view.bounds;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
    _tableView.rowHeight = 48.0;
	_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    if (IS_IPAD) {
        _tableView.separatorInset = UIEdgeInsetsMake(0, 28, 0, 0);
    }
    if ([_category.name isEqualToString:WalletCategoryTypePhoto] || [_category.name isEqualToString:WalletCategoryTypeVideo]) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
	[self.view addSubview:_tableView];
    
    [self.view addSubview:self.addButton];
    [self addButtonConstraints];
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"A3WalletListTextCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3WalletTextCellID1];
    [self.tableView registerClass:[A3WalletListBigVideoCell class] forCellReuseIdentifier:A3WalletBigVideoCellID1];
    [self.tableView registerClass:[A3WalletListBigPhotoCell class] forCellReuseIdentifier:A3WalletBigPhotoCellID1];
}

- (void)showLeftNavigationBarItems
{
    // 현재 more탭바인지 여부 체크
    if (_isFromMoreTableViewController) {
        self.navigationItem.leftItemsSupplementBackButton = YES;
        // more 탭바
        
        self.navigationItem.hidesBackButton = NO;
        
        if (IS_IPAD) {
            if (IS_LANDSCAPE) {
                self.navigationItem.leftBarButtonItem = nil;
            }
            else {
                UIBarButtonItem *appsItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
                self.navigationItem.leftBarButtonItem = appsItem;
            }
        }
        else {
            UIBarButtonItem *appsItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
            self.navigationItem.leftBarButtonItem = appsItem;
        }
    } else {
        // 아님
//        self.navigationItem.hidesBackButton = YES;

		[self leftBarButtonAppsButton];
    }
}

- (void)addButtonConstraints
{
	CGFloat fromBottom = IS_IPAD ? 89.0:82.0;

	[_addButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.centerY.equalTo(self.view.bottom).with.offset(-fromBottom);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];
}

- (void)itemCountCheck
{
    BOOL itemHave = (self.items.count>0) ? YES:NO;
    self.editButtonItem.enabled = itemHave;
}

- (NSMutableArray *)items
{
    if (!_items) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category==%@", _category];
        _items = [NSMutableArray arrayWithArray:[WalletItem MR_findAllSortedBy:@"order" ascending:YES withPredicate:predicate]];
        
        NSUInteger maxCellInWindow = IS_IPHONE ? 8 : 14;
        if (_items.count > maxCellInWindow) {
            self.tableView.tableFooterView = self.footerView;
        }
        else {
            self.tableView.tableFooterView = nil;
        }
    }
    
    return _items;
}

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.tableView.rowHeight)];
    }
    
    return _footerView;
}

- (UIButton *)addButton
{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
        _addButton.frame = CGRectMake(0, 0, 44, 44);
		[_addButton addTarget:self action:@selector(addWalletItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addButton;
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
        _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_infoButton setImage:[UIImage imageNamed:@"information"] forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _infoButton;
}

- (A3WalletCateInfoViewController *)cateInfoViewController
{
    A3WalletCateInfoViewController *viewController = [[A3WalletCateInfoViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.category = _category;
    return viewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing) {
        // editing에서는 멀티 선택 가능하도록
        _tableView.allowsMultipleSelectionDuringEditing = YES;
    } else {
        // editing이 아닐때는 멀티 선택 안되도록 (안되도록 해야, 오른쪽 끝 swipe시에 delete버튼이 나온다.)
        _tableView.allowsMultipleSelectionDuringEditing = NO;
    }
    
    [self.tableView setEditing:editing animated:animated];

    // 뷰 레이아웃 조정
    if (editing) {
        
        self.navigationItem.title = _category.name;
        
        float tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        
        self.addButton.hidden = YES;
        CGRect rect = self.tabBarController.view.frame;
        if (IS_IPHONE) {
            rect.size.height = [UIScreen mainScreen].bounds.size.height + tabBarHeight;
        }
        else {
            if (IS_LANDSCAPE) {
                rect.size.height = [UIScreen mainScreen].bounds.size.width + tabBarHeight;
            }
            else {
                rect.size.height = [UIScreen mainScreen].bounds.size.height + tabBarHeight;
            }
        }
        self.tabBarController.view.frame = rect;
        
        [self setToolbarItems:[self toolItems] animated:YES];
        self.deleteBarItem.enabled = NO;
        self.shareBarItem.enabled = NO;
        [self.navigationController setToolbarHidden:NO animated:NO];
        
        self.navigationItem.rightBarButtonItems = nil;
        
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(editDoneAction:)];
        self.navigationItem.rightBarButtonItem = cancel;
        
        UIBarButtonItem *deleteAll = [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllAction:)];
        self.navigationItem.leftBarButtonItem = deleteAll;
        
        self.navigationItem.hidesBackButton = YES;
    }
    else {
        
        NSString *cateTitle = [NSString stringWithFormat:@"%@(%d)", _category.name, (int)_items.count];
        self.navigationItem.title = cateTitle;
        
        self.addButton.hidden = NO;
        
        CGRect rect = self.tabBarController.view.frame;
        if (IS_IPHONE) {
            rect.size.height = [UIScreen mainScreen].bounds.size.height;
        }
        else {
            if (IS_LANDSCAPE) {
                rect.size.height = [UIScreen mainScreen].bounds.size.width;
            }
            else {
                rect.size.height = [UIScreen mainScreen].bounds.size.height;
            }
        }
        self.tabBarController.view.frame = rect;
        
        [self setToolbarItems:nil animated:YES];
        [self.navigationController setToolbarHidden:YES animated:NO];
        
        /*
        if (IS_IPHONE) {
            [self leftBarButtonAppsButton];
        }
        else {
            self.navigationItem.leftBarButtonItem = nil;
        }
         */

		[self showLeftNavigationBarItems];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = [self rightBarItems];
        
        // editing을 종료하면, item 숫자와 버튼 활성화여부를 결정한다.
        [self itemCountCheck];

    }
}

- (void)shareButtonAction:(id)sender {
    [self shareAll:sender];
}

- (void)infoButtonAction:(id)sender {
	@autoreleasepool {
        [self.navigationController pushViewController:[self cateInfoViewController] animated:YES];
	}
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
    
    if (_items.count > 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete All"
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
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete Items"
                                                        otherButtonTitles:nil];
        actionSheet.tag = 2222;
        [actionSheet showInView:self.view];
    }
}

- (void)shareItemAction:(id)sender {
    @autoreleasepool {
        
        if (self.editing == NO) {
            return;
        }
        
        self.shareTextList = [NSMutableArray new];
        
        NSArray *ips = [self.tableView indexPathsForSelectedRows];
        
        for (NSInteger index = 0; index < ips.count; index++) {
            NSIndexPath *ip = ips[index];
            if ([_items[ip.row] isKindOfClass:[WalletItem class]]) {
                
                WalletItem *item = _items[ip.row];
                NSString *convertInfoText = @"";
                
                if ([_category.name isEqualToString:WalletCategoryTypePhoto]) {
                    NSString *itemName = item.name;
                    NSString *firstFieldItemValue = @"Photo";
                    
                    convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
                }
                else if ([_category.name isEqualToString:WalletCategoryTypeVideo]) {
                    NSString *itemName = item.name;
                    NSString *firstFieldItemValue = @"Video";
                    
                    convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
                }
                else {
                    
                    NSString *itemName = item.name;
                    NSString *firstFieldItemValue = @"";
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
                    NSArray *fieldItems = [item.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
                    if (fieldItems.count>0) {
                        WalletFieldItem *fieldItem = fieldItems[0];
                        NSString *itemValue = @"";
                        if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                            NSDateFormatter *df = [[NSDateFormatter alloc] init];
                            [df setDateFormat:@"MMM dd, YYYY hh:mm a"];
                            itemValue = [df stringFromDate:fieldItem.date];
                        }
                        else {
                            itemValue = fieldItem.value;
                        }
                        
                        if (itemValue && (itemValue.length>0)) {
                            firstFieldItemValue = [itemValue stringForStyle:fieldItem.field.style];
                        }
                    }
                    
                    convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
                }
                
                [_shareTextList addObject:convertInfoText];
            }
        }
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
        [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
            
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
}

- (void)shareAll:(id)sender {
	@autoreleasepool {
        
        self.shareTextList = [NSMutableArray new];
        
        for (NSInteger index = 0; index < _items.count; index++) {
            if ([_items[index] isKindOfClass:[WalletItem class]]) {
                
                WalletItem *item = _items[index];
                NSString *convertInfoText = @"";
                
                if ([_category.name isEqualToString:WalletCategoryTypePhoto]) {
                    NSString *itemName = item.name;
                    NSString *firstFieldItemValue = @"Photo";
                    
                    convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
                }
                else if ([_category.name isEqualToString:WalletCategoryTypeVideo]) {
                    NSString *itemName = item.name;
                    NSString *firstFieldItemValue = @"Video";
                    
                    convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
                }
                else {
                    
                    NSString *itemName = item.name;
                    NSString *firstFieldItemValue = @"";
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
                    NSArray *fieldItems = [item.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
                    if (fieldItems.count>0) {
                        WalletFieldItem *fieldItem = fieldItems[0];
                        NSString *itemValue = @"";
                        if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                            NSDateFormatter *df = [[NSDateFormatter alloc] init];
                            [df setDateFormat:@"MMM dd, YYYY hh:mm a"];
                            itemValue = [df stringFromDate:fieldItem.date];
                        }
                        else {
                            itemValue = fieldItem.value;
                        }
                        
                        if (itemValue && (itemValue.length>0)) {
                            firstFieldItemValue = [itemValue stringForStyle:fieldItem.field.style];
                        }
                    }
                    
                    convertInfoText = [NSString stringWithFormat:@"%@ - %@", itemName, firstFieldItemValue];
                }
                
                [_shareTextList addObject:convertInfoText];
            }
        }
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
        [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
            
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
}

- (A3WalletAddItemViewController *)itemAddViewController
{
    NSString *nibName = (IS_IPHONE) ? @"WalletPhoneStoryBoard" : @"WalletPadStoryBoard";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:nibName bundle:nil];
    A3WalletAddItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletAddItemViewController"];
    viewController.delegate = self;
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.selectedCategory = self.category;
    
    return viewController;
}

- (void)addWalletItemAction {
	A3WalletAddItemViewController *viewController = [self itemAddViewController];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:nav animated:YES completion:NULL];
}

- (void)refreshItems
{
    _items = nil;
    [self.tableView reloadData];
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
        [txt appendString:@"<html><body>I'd like to share a wallet with you.<br/><br/>"];
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"<br/>"];
        }
        [txt appendString:@"<br/>You can wallet more in the AppBox Pro.<br/><a href='https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8'>https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8</a></body></html>"];
        
        return txt;
    }
    else {
        NSMutableString *txt = [NSMutableString new];
        for (int i=0; i<_shareTextList.count; i++) {
            [txt appendString:_shareTextList[i]];
            [txt appendString:@"\n"];
        }
        [txt appendString:@"\nCheck out the AppBox Pro!"];
        
        return txt;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"Share unit converting data";
}

#pragma mark - ActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 1111) {
        // delete all
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            
            for (NSInteger i=_items.count-1; i>=0; i--) {
                if ([_items[i] isKindOfClass:[WalletItem class]]) {
                    
                    WalletItem *item = _items[i];
                    [_items removeObject:item];
                    [item deleteAndClearRelated];
                }
            }
            
            [self.tableView reloadData];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
            
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
                
                if ([_items[indexPath.row] isKindOfClass:[WalletItem class]]) {
                    
                    WalletItem *item = _items[indexPath.row];
                    [item deleteAndClearRelated];
                }
            }
            
            [_items removeObjectsAtIndexes:mis];
            
            [self.tableView deleteRowsAtIndexPaths:ips withRowAnimation:UITableViewRowAnimationFade];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
            
            // 만약 남아있는 _items이 없다면 edit화면을 나간다.
            if (_items.count == 0) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        NSArray *selecteds = [tableView indexPathsForSelectedRows];
        
        if (selecteds.count == 0) {
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
    
    WalletItem *item = _items[indexPath.row];

    if ([item.category.name isEqualToString:WalletCategoryTypePhoto]) {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletPhotoItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletPhotoItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([item.category.name isEqualToString:WalletCategoryTypeVideo]) {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletVideoItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletVideoItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
		[self.navigationController pushViewController:viewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    return [self.items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_category.name isEqualToString:WalletCategoryTypePhoto] || [_category.name isEqualToString:WalletCategoryTypeVideo]) {
        return 84;
    }
    else {
        return 48;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
		if ([[self.items objectAtIndex:indexPath.row] isKindOfClass:[WalletItem class]]) {
            
            WalletItem *item = _items[indexPath.row];
            
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
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] && (fieldItem.filePath.length > 0)) {
                        [photoPick addObject:fieldItem];
                    }
                }

                int maxPhotoCount = (IS_IPAD) ? 5 : 2;
                int showPhotoCount = MIN(maxPhotoCount, (int)photoPick.count);
                
                [photoCell resetThumbImages];
                
                for (int i=0; i<showPhotoCount; i++) {
                    WalletFieldItem *fieldItem = photoPick[i];
                    UIImage *thumbImg = [UIImage imageWithContentsOfFile:[WalletData thumbImgPathOfImgPath:fieldItem.filePath]];
                    
                    [photoCell addThumbImage:thumbImg];
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
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo] && (fieldItem.filePath.length > 0)) {
                        [photoPick addObject:fieldItem];
                    }
                }
                
                int maxPhotoCount = (IS_IPAD) ? 5 : 2;
                int showPhotoCount = MIN(maxPhotoCount, (int)photoPick.count);

                [videoCell resetThumbImages];
                for (int i=0; i<showPhotoCount; i++) {
                    WalletFieldItem *fieldItem = photoPick[i];
                    UIImage *thumbImg = [UIImage imageWithContentsOfFile:[WalletData thumbImgPathOfVideoPath:fieldItem.filePath]];
                    float duration = [WalletData getDurationOfMovie:fieldItem.filePath];
                    [videoCell addThumbImage:thumbImg withDuration:duration];
                }
                
                cell = videoCell;
            }
            else {
                /*
                A3WalletListTextCell *dataCell;
                dataCell = [tableView dequeueReusableCellWithIdentifier:A3WalletTextCellID1 forIndexPath:indexPath];
                
                dataCell.titleLabel.text = item.name;
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
                NSArray *fieldItems = [item.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
                if (fieldItems.count>0) {
                    WalletFieldItem *fieldItem = fieldItems[0];
                    NSString *itemValue = @"";
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"MMM dd, YYYY hh:mm a"];
                        itemValue = [df stringFromDate:fieldItem.date];
                    }
                    else {
                        itemValue = fieldItem.value;
                    }
                    
                    if (itemValue && (itemValue.length>0)) {
                        NSString *styleValue = [itemValue stringForStyle:fieldItem.field.style];
                        dataCell.detailLabel.text = styleValue;
                    }
                    else {
                        dataCell.detailLabel.text = @"";
                    }
                }
                else {
                    dataCell.detailLabel.text = @"";
                }
                
                cell = dataCell;
                 */
                
                UITableViewCell *dataCell;
                dataCell = [tableView dequeueReusableCellWithIdentifier:A3WalletTextCellID1];
                if (dataCell == nil) {
                    dataCell = [[UITableViewCell alloc] initWithStyle:IS_IPAD ? UITableViewCellStyleValue1:UITableViewCellStyleSubtitle reuseIdentifier:A3WalletTextCellID1];
                    dataCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    dataCell.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
                    
                    if (IS_IPHONE) {
                        dataCell.textLabel.font = [UIFont systemFontOfSize:15];
                        dataCell.detailTextLabel.font = [UIFont systemFontOfSize:12];
                    }
                    else {
                        dataCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
                        dataCell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
                    }
                }
                
                if (item.name && item.name.length>0) {
                    dataCell.textLabel.text = item.name;
                }
                else {
                    dataCell.textLabel.text = @"New Item";
                }
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
                NSArray *fieldItems = [item.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
                if (fieldItems.count>0) {
                    WalletFieldItem *fieldItem = fieldItems[0];
                    NSString *itemValue = @"";
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"MMM dd, YYYY hh:mm a"];
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
		}
	}
    
    return cell;
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
        
        if ([_items[indexPath.row] isKindOfClass:[WalletItem class]]) {
            
            WalletItem *item = _items[indexPath.row];
            [_items removeObject:item];
            [item deleteAndClearRelated];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
            
            // more button 활성화여부
            [self itemCountCheck];
            
            // 타이틀 표시 (갯수가 있으므로 페이지 진입시 갱신한다.)
            NSString *cateTitle = [NSString stringWithFormat:@"%@(%d)", _category.name, (int)_items.count];
            self.navigationItem.title = cateTitle;
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    @autoreleasepool {
		[self.items moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
	}
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
