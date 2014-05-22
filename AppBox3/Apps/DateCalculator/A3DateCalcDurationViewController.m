//
//  A3DateCalcDurationViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcDurationViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3RootViewController_iPad.h"
#import "A3DateCalcStateManager.h"
#import "A3DateCalcTableviewCell.h"
#import "A3DefaultColorDefines.h"

static NSString *CellIdentifier = @"Cell";

@interface A3DateCalcDurationViewController ()

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation A3DateCalcDurationViewController

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

    self.title = @"Duration";
    
    if (IS_IPHONE) {
        [self makeBackButtonEmptyArrow];
    }
    
    _sectionTitles = @[@""];
    _sections = @[@[@"Year", @"Month", @"Week", @"Day"]];
    
	[self.tableView registerClass:[A3DateCalcTableviewCell class] forCellReuseIdentifier:CellIdentifier];
	[self.tableView setShowsHorizontalScrollIndicator:NO];
	[self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
		if ([_delegate respondsToSelector:@selector(dismissDateCalcDurationViewController)]) {
			[_delegate performSelector:@selector(dismissDateCalcDurationViewController)];
		}

	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3DateCalcTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.sections[indexPath.section][indexPath.row];
    //cell.textLabel.font = FONT_TABLE_TEXTLABEL_DEFAULT_SIZE(17);
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.userInteractionEnabled = YES;
    
    switch (indexPath.row) {
        case 0:
        {
            cell.accessoryType = [A3DateCalcStateManager durationType] & DurationType_Year? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
            break;
        case 1:
        {
            cell.accessoryType = [A3DateCalcStateManager durationType] & DurationType_Month? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
            break;
        case 2:
        {
            cell.accessoryType = [A3DateCalcStateManager durationType] & DurationType_Week? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
            break;
        case 3:
        {
            cell.accessoryType = [A3DateCalcStateManager durationType] & DurationType_Day? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1.0];
        }
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
        {
            [A3DateCalcStateManager setDurationType:DurationType_Year];
            cell.accessoryType = [A3DateCalcStateManager durationType] & DurationType_Year? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
            break;
        case 1:
        {
            [A3DateCalcStateManager setDurationType:DurationType_Month];
            cell.accessoryType = [A3DateCalcStateManager durationType] & DurationType_Month? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
            break;
        case 2:
        {
            [A3DateCalcStateManager setDurationType:DurationType_Week];
            cell.accessoryType = [A3DateCalcStateManager durationType] & DurationType_Week? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
            break;
    }

    if ([self.delegate respondsToSelector:@selector(durationSettingChanged)]) {
        [self.delegate durationSettingChanged];
    }
}

@end
