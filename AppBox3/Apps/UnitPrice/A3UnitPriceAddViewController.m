//
//  A3UnitPriceAddViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceAddViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3UnitDataManager.h"

@interface A3UnitPriceAddViewController ()

@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, strong) NSMutableArray *favorites;

@end

@implementation A3UnitPriceAddViewController

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
    
    self.title = [_dataManager localizedCategoryNameForID:_categoryID];

    self.tableView.rowHeight = 44.0;
	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];

    [self rightBarButtonDoneButton];
    self.navigationItem.hidesBackButton = YES;

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissRightSideView) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)removeObserver {
	if (IS_IPAD) {
		FNLOG();
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)willDismissRightSideView {
	[self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	NSArray *originalFavorites = [_dataManager unitPriceFavoriteForCategoryID:_categoryID];
	if (![originalFavorites isEqualToArray:_favorites]) {
		[_dataManager saveUnitPriceFavorites:_favorites categoryID:_categoryID];
		if ([_delegate respondsToSelector:@selector(addViewControllerDidUpdateData)]) {
			[_delegate addViewControllerDidUpdateData];
		}
	}

	if (_shouldPopViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)favorites
{
    if (!_favorites) {
		_favorites = [_dataManager unitPriceFavoriteForCategoryID:_categoryID];
    }
    
    return _favorites;
}

- (NSMutableArray *)allData {
	if (!_allData) {
		_allData = [_dataManager allUnitsSortedByLocalizedNameForCategoryID:_categoryID];
	}
	return _allData;
}

-(void)addButtonClicked:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    NSDictionary *item = _allData[indexPath.row];
    
    if ([self.favorites containsObject:item[ID_KEY]]) {
        [_favorites removeObject:item[ID_KEY]];
    }
    else {
        [_favorites addObject:item[ID_KEY]];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    return [self.allData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage imageNamed:@"add04"] forState:UIControlStateNormal];
        [addButton setImage:[UIImage imageNamed:@"add05"] forState:UIControlStateSelected];
        addButton.frame = CGRectMake(0, 0, 27, 27);
        [addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addButton;
    }
    
    // Configure the cell...
    NSDictionary *item = _allData[indexPath.row];
    cell.textLabel.text = item[NAME_KEY];
    
    UIButton *plusBtn = (UIButton *)cell.accessoryView;
    plusBtn.tag = indexPath.row;
    if ([self.favorites containsObject:item[ID_KEY]]) {
        plusBtn.selected = YES;
        cell.textLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
    }
    else {
        plusBtn.selected = NO;
        cell.textLabel.textColor = [UIColor blackColor];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = _allData[indexPath.row];
    
    if ([self.favorites containsObject:item[ID_KEY]]) {
        [self.favorites removeObject:item[ID_KEY]];
    }
    else {
        [self.favorites addObject:item[ID_KEY]];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
