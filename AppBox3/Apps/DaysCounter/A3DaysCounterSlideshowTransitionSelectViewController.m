//
//  A3DaysCounterSlideshowTransitionSelectViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSlideshowTransitionSelectViewController.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"

@interface A3DaysCounterSlideshowTransitionSelectViewController ()
@property (strong, nonatomic) NSArray *itemArray;
@end

@implementation A3DaysCounterSlideshowTransitionSelectViewController

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

    self.title = @"Transitions";
    [self makeBackButtonEmptyArrow];
    self.itemArray = @[@(TransitionType_Cube),@(TransitionType_Dissolve),@(TransitionType_Origami),@(TransitionType_Ripple),@(TransitionType_Wipe)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    }
    
    NSInteger type = [[_itemArray objectAtIndex:indexPath.row] integerValue];
    cell.textLabel.text = [[A3DaysCounterModelManager sharedManager] stringForSlideshowTransitionType:type];
    cell.accessoryType = ( type == [[_optionDict objectForKey:OptionKey_Transition] integerValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone );
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger currentType = [[_optionDict objectForKey:OptionKey_Transition] integerValue];
    NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:currentType inSection:indexPath.section];
    
    [_optionDict setObject:@(indexPath.row) forKey:OptionKey_Transition];
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[prevIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

@end
