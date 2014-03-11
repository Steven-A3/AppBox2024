//
//  A3WalletCateInfoViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCateInfoViewController.h"
#import "A3WalletCateTitleView.h"
#import "A3WalletCateInfoFieldCell.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "WalletField.h"
#import "WalletData.h"
#import "NSDate+TimeAgo.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"

@interface A3WalletCateInfoViewController ()

@property (nonatomic, strong) A3WalletCateTitleView *headerView;

@end

@implementation A3WalletCateInfoViewController

NSString *const A3WalletCateInfoFieldCellID = @"A3WalletCateInfoFieldCell";

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Category Info";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction:)];
    
    NSString *nibName = IS_IPAD ? @"A3WalletCateInfoFieldCell_iPad" : @"A3WalletCateInfoFieldCell";
    [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3WalletCateInfoFieldCellID];
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, IS_IPAD ? 28+30+28:15+30+15, 0, 0);
    self.tableView.rowHeight = 74.0;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeperatorColor];
    
    _headerView.icon.image = [UIImage imageNamed:_category.icon];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (A3WalletCateTitleView *)headerView
{
    if (!_headerView) {
        NSString *nibName = IS_IPAD ? @"A3WalletCateTitleView_iPad" : @"A3WalletCateTitleView";
        _headerView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:Nil options:nil] lastObject];
        
        _headerView.nameLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0];
        _headerView.timeLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0];
        _headerView.nameLabel.text = _category.name;
        _headerView.icon.image = [UIImage imageNamed:_category.icon];
        _headerView.timeLabel.text = [NSString stringWithFormat:@"Updated %@",  [_category.modificationDate timeAgo]];
    }
    
    return _headerView;
}

- (void)editButtonAction:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletCateEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletCateEditViewController"];

    viewController.delegate = self;
    viewController.category = _category;
    
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
        [self.navigationController presentViewController:nav animated:YES completion:NULL];
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

- (void)walletCategoryEdited:(WalletCategory *)category
{
    // category 정보가 변경됨.
    [self.tableView reloadData];
    
    _headerView.nameLabel.text = _category.name;
    _headerView.icon.image = [UIImage imageNamed:_category.icon];
    
    // 하단에 탭바에 표시되는 카테고리 정보 갱신을 위해 노티를 날린다.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoryEdited" object:nil];
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
    return _category.fields.count;
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
    
	NSArray *items = [_category fieldsArray];
    WalletField *field = items[indexPath.row];
    
    // Configure the cell...
    cell.nameLabel.text = field.name;
    if ([field.type isEqualToString:WalletFieldTypeImage] || [field.type isEqualToString:WalletFieldTypeVideo]) {
        cell.typeLabel.text = field.type;
    }
    else {
        cell.typeLabel.text = [NSString stringWithFormat:@"%@, %@", field.type, field.style];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
