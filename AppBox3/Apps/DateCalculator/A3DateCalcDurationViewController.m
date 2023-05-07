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
#import "UIImage+JHExtension.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

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

    self.title = NSLocalizedString(@"Duration", @"Duration");
    
    if (IS_IPHONE) {
        [self makeBackButtonEmptyArrow];
    }
    
    _sectionTitles = @[@""];
    _sections = @[
			@[
					NSLocalizedString(@"Years", @"Years"),
					NSLocalizedString(@"Months", @"Months"),
					NSLocalizedString(@"Weeks", @"Weeks"),
					[NSString stringWithFormat:@"%@(%@)", NSLocalizedString(@"Days", @"Days"), NSLocalizedString(@"Default", @"Default")],
	]
	];
    
	[self.tableView registerClass:[A3DateCalcTableviewCell class] forCellReuseIdentifier:CellIdentifier];
	[self.tableView setShowsHorizontalScrollIndicator:NO];
	[self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
    self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
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
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.userInteractionEnabled = YES;

    switch (indexPath.row) {
        case 0:
        {
            cell.accessoryView = [A3DateCalcStateManager durationType] & DurationType_Year? [self checkImageView] : nil;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
            break;
        case 1:
        {
            cell.accessoryView = [A3DateCalcStateManager durationType] & DurationType_Month? [self checkImageView] : nil;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
            break;
        case 2:
        {
            cell.accessoryView = [A3DateCalcStateManager durationType] & DurationType_Week? [self checkImageView] : nil;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
            break;
        case 3:
        {
            cell.accessoryView = [A3DateCalcStateManager durationType] & DurationType_Day? [[UIImageView alloc] initWithImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"check_02"] grayColor:[UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0]]] : nil;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1.0];
        }
            break;
    }
    
    return cell;
}

- (UIImageView *)checkImageView {
	UIImageView *checkImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"check_02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    checkImageView.tintColor = [[A3UserDefaults standardUserDefaults] themeColor];
	return checkImageView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
        {
            [A3DateCalcStateManager setDurationType:DurationType_Year];
            cell.accessoryView = [A3DateCalcStateManager durationType] & DurationType_Year? [self checkImageView] : nil;
			break;
		}
        case 1:
        {
            [A3DateCalcStateManager setDurationType:DurationType_Month];
            cell.accessoryView = [A3DateCalcStateManager durationType] & DurationType_Month? [self checkImageView] : nil;
			break;
		}
        case 2:
        {
            [A3DateCalcStateManager setDurationType:DurationType_Week];
            cell.accessoryView = [A3DateCalcStateManager durationType] & DurationType_Week? [self checkImageView] : nil;
			break;
		}
    }

    if ([self.delegate respondsToSelector:@selector(durationSettingChanged)]) {
        [self.delegate durationSettingChanged];
    }
}

@end
