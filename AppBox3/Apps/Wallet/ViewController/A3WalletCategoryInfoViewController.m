//
//  A3WalletCategoryInfoViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCategoryInfoViewController.h"
#import "A3WalletCateTitleView.h"
#import "A3WalletCateInfoFieldCell.h"
#import "WalletData.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3WalletMainTabBarController.h"
#import "NSDateFormatter+A3Addition.h"
#import "NSDate+formatting.h"
#import "WalletItem.h"

NSString *const A3WalletCateInfoFieldCellID = @"A3WalletCateInfoFieldCell";

@interface A3WalletCategoryInfoViewController ()

@property (nonatomic, strong) A3WalletCateTitleView *headerView;

@end

@implementation A3WalletCategoryInfoViewController {
	BOOL _categoryContentsChanged;
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

    self.navigationItem.title = NSLocalizedString(@"Category Info", @"Category Info");

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction:)];

	NSString *nibName = IS_IPAD ? @"A3WalletCateInfoFieldCell_iPad" : @"A3WalletCateInfoFieldCell";
    [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3WalletCateInfoFieldCellID];
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, IS_IPAD ? 28+30+28:15+30+15, 0, 0);
    self.tableView.rowHeight = 74.0;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
    _headerView.icon.image = [UIImage imageNamed:_category[W_ICON_KEY]];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];

		if (_categoryContentsChanged) {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3WalletNotificationCategoryChanged object:nil];
		}
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
	[self setupHeaderViewFont];
    [self.tableView reloadData];
}

- (A3WalletCateTitleView *)headerView
{
    if (!_headerView) {
        NSString *nibName = IS_IPAD ? @"A3WalletCateTitleView_iPad" : @"A3WalletCateTitleView";
        _headerView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:Nil options:nil] lastObject];
		[self setupHeaderViewFont];
        _headerView.nameLabel.text = _category[W_NAME_KEY];
        _headerView.icon.image = [UIImage imageNamed:_category[W_ICON_KEY]];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        if (IS_IPAD || [NSDate isFullStyleLocale]) {
            dateFormatter.dateStyle = NSDateFormatterFullStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            dateFormatter.doesRelativeDateFormatting = YES;
        }
        else {
            dateFormatter.dateFormat = [dateFormatter customFullWithTimeStyleFormat];
        }

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", _category[W_ID_KEY]];
		WalletItem *item = [WalletItem MR_findFirstWithPredicate:predicate sortedBy:@"updateDate" ascending:NO];
		if (item) {
			_headerView.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Updated %@", @"Updated %@"), [dateFormatter stringFromDate:item.updateDate]];
		}
    }
    
    return _headerView;
}

- (void)setupHeaderViewFont {
	_headerView.nameLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0];
	_headerView.timeLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0];
}

- (void)editButtonAction:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletCategoryEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletCategoryEditViewController"];

    viewController.delegate = self;
    viewController.categoryID = _category[W_ID_KEY];
    
    [self presentSubViewController:viewController];
}

- (void)presentSubViewController:(UIViewController *)viewController {
	if (IS_IPAD) {
        [self.navigationController pushViewController:viewController animated:NO];
        
        // custom cross dissolve animation
        viewController.view.alpha = 0.0;
        [UIView animateWithDuration: 0.3
                         animations:^{
                             self.view.alpha = 0.0;
                             viewController.view.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             self.view.alpha = 1.0;
                         }];
        
    }
    else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:nav animated:YES completion:NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WalletCateEditDelegate
- (void)walletCateEditCanceled
{
    
}

- (void)walletCategoryEdited:(NSDictionary *)category
{
    // category 정보가 변경됨.
    [self.tableView reloadData];
    
    _headerView.nameLabel.text = _category[W_NAME_KEY];
    _headerView.icon.image = [UIImage imageNamed:_category[W_ICON_KEY]];

	_categoryContentsChanged = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *fields = _category[W_FIELDS_KEY];
    return [fields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3WalletCateInfoFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:A3WalletCateInfoFieldCellID];
	if (nil == cell) {
		cell = [[A3WalletCateInfoFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3WalletCateInfoFieldCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.nameLabel.font = [UIFont systemFontOfSize:14];
        cell.typeLabel.font = [UIFont systemFontOfSize:17];
        cell.typeLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
	}
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	NSArray *items = _category[W_FIELDS_KEY];
    NSDictionary *field = items[indexPath.row];
    
    // Configure the cell...
    cell.nameLabel.text = field[W_NAME_KEY];
    if ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypeImage] || [field[W_TYPE_KEY] isEqualToString:WalletFieldTypeVideo]) {
        cell.typeLabel.text = NSLocalizedString(field[W_TYPE_KEY], nil);
    }
    else {
        cell.typeLabel.text = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(field[W_TYPE_KEY], nil), NSLocalizedString(field[W_STYLE_KEY], nil)];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        return IS_RETINA ? 74.5 : 75.0;
    }
    
    return 74.0;
}

@end
