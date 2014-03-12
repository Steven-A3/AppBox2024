//
//  A3TipCalcRoundingViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TipCalcRoundingViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3TipCalcDataManager.h"
#import "TipCalcRoundMethod.h"
#import "TipCalcRecently.h"
#import "NSUserDefaults+A3Defaults.h"

@interface A3TipCalcRoundingViewController ()

@end

@implementation A3TipCalcRoundingViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _arrSectionTitle = @[@"VALUE", @"Option"];
        _mdicCellText = [@{[_arrSectionTitle objectAtIndex:0]: @[@"Tip", @"Total", @"Total Per Person", @"Tip Per Person"],
                           [_arrSectionTitle objectAtIndex:1]: @[@"Exact", @"Up", @"Down", @"Off"]}
                         mutableCopy];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.title = @"Rounding Method";
    [self rightBarButtonDoneButton];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    
    self.tableView.rowHeight = 42.0;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;

}


- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
        [self.navigationController popViewControllerAnimated:YES];
	}
}

// elf 수정중
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrSectionTitle.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _arrSectionTitle[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* arrCellText = [_mdicCellText objectForKey:[_arrSectionTitle objectAtIndex:section]];
    
    return arrCellText.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 1? 36.0 : 56.0 ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float fRst = 42.0;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == TipCalcRoundingTargetTotalPerPerson || indexPath.row == TipCalcRoundingTargetTipPerPerson)
        {
            if (![[A3TipCalcDataManager sharedInstance] isSplitOptionOn])
                fRst = 0.0f;
        }
    }
    
    return fRst;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell=nil;
	@autoreleasepool {
        NSArray* arrCellText = [_mdicCellText objectForKey:[_arrSectionTitle objectAtIndex:indexPath.section]];
        NSString* strCellText = [arrCellText objectAtIndex:indexPath.row];
        NSString* strCellIndentifier = [[_arrSectionTitle objectAtIndex:indexPath.section] stringByAppendingString:@"TipCalcRoundingTableCell"];
        
        cell = [tableView dequeueReusableCellWithIdentifier:strCellIndentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:strCellIndentifier];
        }
        
        cell.textLabel.text = strCellText;
        
        if(indexPath.section == 0) {
            cell.accessoryType = [[A3TipCalcDataManager sharedInstance] roundingMethodValue] == (TCRoundingMethodValue_Tip + indexPath.row) ?UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if(indexPath.section == 1) {
            cell.accessoryType = [[A3TipCalcDataManager sharedInstance] roundingMethodOption] == (TCRoundingMethodOption_Exact + indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
	}
    
    return cell;
}

#pragma mark - tableview delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        return;
    }
    
    for(int i = 0; i < 4; i++) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        UITableViewCell* cellUnSel = [tableView cellForRowAtIndexPath:path];
        cellUnSel.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if(indexPath.section == 0) {
        [A3TipCalcDataManager sharedInstance].roundingMethodValue = TCRoundingMethodValue_Tip + indexPath.row;
    }
    else if(indexPath.section == 1) {
        [A3TipCalcDataManager sharedInstance].roundingMethodOption = TCRoundingMethodOption_Exact + indexPath.row;
    }
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if ([_delegate respondsToSelector:@selector(tipCalcRoundingChanged)]) {
        [_delegate tipCalcRoundingChanged];
    }
}

@end
