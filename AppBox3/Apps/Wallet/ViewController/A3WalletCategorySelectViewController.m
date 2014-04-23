//
//  A3WalletCategorySelectViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCategorySelectViewController.h"
#import "WalletCategory.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "WalletCategory+initialize.h"

@interface A3WalletCategorySelectViewController ()

@property (nonatomic, strong) NSMutableArray *allCategories;

@end

@implementation A3WalletCategorySelectViewController

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
    
    self.navigationItem.title = @"Categories";
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	NSUInteger indexOfSelectedCategory = [self.allCategories indexOfObject:_selectedCategory];
	if (indexOfSelectedCategory != NSNotFound) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfSelectedCategory inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (NSMutableArray *)allCategories
{
    if (!_allCategories) {
        _allCategories = [NSMutableArray arrayWithArray:[WalletCategory MR_findAllSortedBy:@"order" ascending:YES]];
        
        WalletCategory *favCate = [WalletCategory favoriteCategory];
        WalletCategory *allCate = [WalletCategory allCategory];
        
        if (favCate) {
            [_allCategories removeObject:favCate];
        }
        if (allCate) {
            [_allCategories removeObject:allCate];
        }
    }
    
    return _allCategories;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonAction:(id)button {
	@autoreleasepool {
        
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
        }
        else {
            [self.A3RootViewController dismissRightSideViewController];
        }
	}
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
    return self.allCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    }
    
    // Configure the cell...
    WalletCategory *cate = _allCategories[indexPath.row];
    cell.textLabel.text = cate.name;
    
    if (cate == _selectedCategory) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(walletCategorySelected:)]) {
        
        WalletCategory *category = self.allCategories[indexPath.row];
        [_delegate walletCategorySelected:category];
    }
    
    if (IS_IPHONE) {
        [self.navigationController popViewControllerAnimated:YES];
	}
}

@end
