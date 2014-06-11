//
//  A3DaysCounterSlideshowTimeSelectViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSlideshowTimeSelectViewController.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"

@interface A3DaysCounterSlideshowTimeSelectViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@end

@implementation A3DaysCounterSlideshowTimeSelectViewController

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

    self.title = NSLocalizedString(@"Play Each Slide For", @"Play Each Slide For");
    [self makeBackButtonEmptyArrow];
    self.itemArray = @[@(2),@(3),@(5),@(10),@(20)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.itemArray = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger seconds = [[_itemArray objectAtIndex:indexPath.row] integerValue];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld seconds", @"StringsDict", nil), (long)seconds];
    cell.accessoryType = (seconds == [[_optionDict objectForKey:OptionKey_Showtime] integerValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [_itemArray indexOfObject:[_optionDict objectForKey:OptionKey_Showtime]];
    NSIndexPath *prevIndexPath = nil;
    if( index != NSNotFound ){
        prevIndexPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
    }
    
    [_optionDict setObject:[_itemArray objectAtIndex:indexPath.row] forKey:OptionKey_Showtime];
    [tableView beginUpdates];
    if( prevIndexPath && (prevIndexPath.row != indexPath.row) )
        [tableView reloadRowsAtIndexPaths:@[prevIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
