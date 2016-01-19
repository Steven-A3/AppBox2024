//
//  A3UnitConverterAddViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterAddViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3UnitDataManager.h"
#import "A3StandardTableViewCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UIDevice.h"

@interface A3UnitConverterAddViewController ()

@property (nonatomic, strong) NSMutableArray *favorites;

@end

@implementation A3UnitConverterAddViewController

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

    [self rightBarButtonDoneButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = 44.0;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)willDismissRightSideView {
	[self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	NSArray *savedFavorites = [_dataManager favoritesForCategoryID:_categoryID];

	if (![savedFavorites isEqualToArray:_favorites]) {
		[_dataManager saveFavorites:_favorites categoryID:_categoryID];
		if ([_delegate respondsToSelector:@selector(favoritesUpdatedInAddViewController)]) {
			[_delegate favoritesUpdatedInAddViewController];
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
		_favorites = [NSMutableArray arrayWithArray:[_dataManager favoritesForCategoryID:_categoryID]];
    }
    
    return _favorites;
}

-(void)addButtonClicked:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
	[self toggleFavoritesAtIndexPath:indexPath];
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
    return [_allData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage imageNamed:@"add04"] forState:UIControlStateNormal];
        [addButton setImage:[UIImage imageNamed:@"add05"] forState:UIControlStateSelected];
        addButton.frame = CGRectMake(0, 0, 27, 27);
        [addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addButton;
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
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
    [self toggleFavoritesAtIndexPath:indexPath];
}

- (void)toggleFavoritesAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *item = _allData[indexPath.row];

	if ([self.favorites containsObject:item[ID_KEY]]) {
		[_favorites removeObject:item[ID_KEY]];
	}
	else {
		[_favorites addObject:item[ID_KEY]];
	}

	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
