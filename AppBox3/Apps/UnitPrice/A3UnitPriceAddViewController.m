//
//  A3UnitPriceAddViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 4..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceAddViewController.h"

#import "UnitItem.h"
#import "UnitType.h"
#import "UnitPriceFavorite.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+iPad_rightSideView.h"

@interface A3UnitPriceAddViewController ()

@property (nonatomic, strong) NSMutableArray *addedItems;

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
    
    UnitItem *firstItem = _allData[0];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ Units", @"%@ Units"), NSLocalizedStringFromTable(firstItem.type.unitTypeName, @"unit", nil)];
    
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
		FNLOG();
		[self removeObserver];
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
    // 변경 사항 있는지 체크한다
    NSMutableArray *favoredItems = [[NSMutableArray alloc] init];
    for (UnitItem *item in _allData) {
        if ([self isFavoriteItemForUnitItem:item]) {
            [favoredItems addObject:item];
        }
    }
    
    NSMutableArray *toAddItems = [[NSMutableArray alloc] init];
    
    for (UnitItem *item in _addedItems) {
        if ([favoredItems containsObject:item]) {
            [favoredItems removeObject:item];
        }
        else {
            [toAddItems addObject:item];
        }
    }
    
    // favoredItems에서 남겨진건 remove해야할 item이고, toAddItems 추가해야할 item 들임
    BOOL isChanged = (toAddItems.count > 0) || (favoredItems.count > 0);
    
    if (isChanged) {
        if ([_delegate respondsToSelector:@selector(addViewController:itemsAdded:itemsRemoved:)]) {
            [_delegate addViewController:self itemsAdded:toAddItems itemsRemoved:favoredItems];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(willDismissAddViewController)]) {
            [_delegate willDismissAddViewController];
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

- (NSMutableArray *)addedItems
{
    if (!_addedItems) {
        _addedItems = [[NSMutableArray alloc] init];
        for (UnitItem *item in _allData) {
            if ([self isFavoriteItemForUnitItem:item]) {
                [_addedItems addObject:item];
            }
        }
    }
    
    return _addedItems;
}

-(void)addButtonClicked:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    UnitItem *item = _allData[indexPath.row];
    
    if ([self.addedItems containsObject:item]) {
        [_addedItems removeObject:item];
    }
    else {
        [_addedItems addObject:item];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)isFavoriteItemForUnitItem:(id)object
{
    NSArray *result = [UnitPriceFavorite MR_findByAttribute:@"item" withValue:object];
	return [result count] > 0;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage imageNamed:@"add04"] forState:UIControlStateNormal];
        [addButton setImage:[UIImage imageNamed:@"add05"] forState:UIControlStateSelected];
        addButton.frame = CGRectMake(0, 0, 27, 27);
        [addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addButton;
    }
    
    // Configure the cell...
    UnitItem *item = _allData[indexPath.row];
    cell.textLabel.text = NSLocalizedStringFromTable(item.unitName, @"unit", nil);
    
    UIButton *plusBtn = (UIButton *)cell.accessoryView;
    plusBtn.tag = indexPath.row;
    if ([self.addedItems containsObject:item]) {
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
    
    UnitItem *item = _allData[indexPath.row];
    
    if ([self.addedItems containsObject:item]) {
        [_addedItems removeObject:item];
    }
    else {
        [_addedItems addObject:item];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
