//
//  A3UnitConverterAddViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterAddViewController.h"
#import "UnitItem.h"
#import "UnitType.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+UnitConverter.h"
#import "UIViewController+iPad_rightSideView.h"

@interface A3UnitConverterAddViewController ()

@property (nonatomic, strong) NSMutableArray *addedItems;

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

    UnitItem *firstItem = _allData[0];
    self.title = [NSString stringWithFormat:@"%@ Units", firstItem.type.unitTypeName];
    
    [self rightBarButtonDoneButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = 44.0;
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
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    }
    
    // Configure the cell...
    UnitItem *item = _allData[indexPath.row];
    cell.textLabel.text = item.unitName;
    
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
