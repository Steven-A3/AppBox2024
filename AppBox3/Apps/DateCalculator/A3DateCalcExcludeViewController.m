//
//  A3DateCalcExcludeViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcExcludeViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DateCalcStateManager.h"
#import "A3DateCalcTableviewCell.h"
#import "A3DefaultColorDefines.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+imageWithColor.h"

static NSString *CellIdentifier = @"Cell";

@interface A3DateCalcExcludeViewController ()

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation A3DateCalcExcludeViewController
{
}

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
    
    self.title = NSLocalizedString(@"Exclude", @"Exclude");

//    if (IS_IPAD) {
//        [self rightBarButtonDoneButton];
//    } else {
//        [self makeBackButtonEmptyArrow];        
//    }
    if (IS_IPHONE) {
        [self makeBackButtonEmptyArrow];
    }
    
    self.sectionTitles = @[@"", @""];
    self.sections = @[
                  @[
						  NSLocalizedString(@"None", @"None")
				  ],
                  @[
						  NSLocalizedString(@"Saturday", @"Saturday"),
						  NSLocalizedString(@"Sunday", @"Sunday")
				  ]
//                  @[@"Saturday", @"Sunday", @"Public Holidays"]
                  ];
    
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
	[self.tableView setShowsHorizontalScrollIndicator:NO];
	[self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
		if ([_delegate respondsToSelector:@selector(dismissExcludeSettingViewController)]) {
			[_delegate performSelector:@selector(dismissExcludeSettingViewController)];
		}

	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.sections[indexPath.section][indexPath.row];;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    
    switch (indexPath.section) {
        case 0:
        {
            cell.accessoryType = [A3DateCalcStateManager excludeOptions] == ExcludeOptions_None ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
            break;
            
        case 1:
        {
            ExcludeOptions options = [A3DateCalcStateManager excludeOptions];
            switch (indexPath.row) {
                case 0:
                {
                    cell.accessoryType = options & ExcludeOptions_Saturday ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                }
                    break;
                case 1:
                {
                    cell.accessoryType = options & ExcludeOptions_Sunday ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                }
                    break;
                case 2:
                {
                    cell.accessoryType = options & ExcludeOptions_PublicHoliday ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                }
                    break;
            }
        }
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 && indexPath.row==0) {
        [A3DateCalcStateManager setExcludeOptions:ExcludeOptions_None];
        
    }
    else if (indexPath.section==1) {
        switch (indexPath.row) {
            case 0:
            {
                [A3DateCalcStateManager setExcludeOptions:ExcludeOptions_Saturday];
            }
                break;
            case 1:
            {
                [A3DateCalcStateManager setExcludeOptions:ExcludeOptions_Sunday];
            }
                break;
            case 2:
            {
                [A3DateCalcStateManager setExcludeOptions:ExcludeOptions_PublicHoliday];
            }
                break;
        }
    }
    
    ExcludeOptions options = [A3DateCalcStateManager excludeOptions];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.accessoryType = options == ExcludeOptions_None ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.accessoryType = options & ExcludeOptions_Saturday ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    cell.accessoryType = options & ExcludeOptions_Sunday ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(excludeSettingDelegate)]) {
        [_delegate performSelector:@selector(excludeSettingDelegate)];
    }
}


@end
