//
//  A3DateCalcEditEventViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcEditEventViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DateCalcTableRowData.h"
#import "A3DefaultColorDefines.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3DateCalcEditEventViewController ()

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *selectedObjectInfo;

@end

@implementation A3DateCalcEditEventViewController

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
    
    self.title = NSLocalizedString(@"Edit Event", @"Edit Event");
    
    if (IS_IPAD) {
        [self rightBarButtonDoneButton];
    } else {
        [self makeBackButtonEmptyArrow];
    }
    
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier_Common];
	[self.tableView setShowsHorizontalScrollIndicator:NO];
	[self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
    if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    }

    [self reloadTableViewData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)doneButtonAction:(id)sender
{
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
		if ([_delegate respondsToSelector:@selector(dismissEditEventViewController)]) {
			[_delegate performSelector:@selector(dismissEditEventViewController)];
		}

	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)switchButtonAction:(id)sender
{
    FNLOG(@"%@", sender);
}

- (void)accessoryButtonTouchUp:(id)sender
{
    
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
    A3DateCalcTableRowData *rowData = self.sectionTitles[section];
    if (!rowData) {
        return @"";
    }
    
    return rowData.textString;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (section==2) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"arrow"];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:image forState:UIControlStateHighlighted];
        
        // Rotate 90 degrees to hide it off screen
        CGAffineTransform rotationTransform = CGAffineTransformIdentity;
        rotationTransform = CGAffineTransformRotate(rotationTransform, DegreesToRadians(90));
        button.transform = rotationTransform;
        [view addSubview:button];
        
        button.frame = CGRectMake(CGRectGetWidth(view.frame)-22.0, CGRectGetHeight(view.frame)-25.0, 16.0, 8.0);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell = [self cellFor:cell WithRowData:self.sections[indexPath.section][indexPath.row] indexPath:indexPath];
    
    return cell;
}

-(UITableViewCell *)cellFor:(UITableViewCell *)aCell WithRowData:(A3DateCalcTableRowData *)rowData indexPath:(NSIndexPath *)indexPath
{
    if (!aCell) {
        aCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rowData.cellIdentifier];
    }
    
    if ([rowData.cellIdentifier isEqualToString:kCellIdentifier_Separator]) {
        
        [aCell.contentView setBackgroundColor:[UIColor clearColor]];
        [aCell setBackgroundColor:[UIColor clearColor]];
        [aCell.textLabel setText:rowData.textString];
        
    } else if ([rowData.cellIdentifier isEqualToString:kCellIdentifier_Common]) {
        
        [aCell.contentView setBackgroundColor:[UIColor whiteColor]];
        
        [aCell.textLabel setText:rowData.textString];
        [aCell.detailTextLabel setText:rowData.detailTextString];
        
        switch (rowData.accessoryType) {
            case Accessory_CheckMark:
                aCell.accessoryType = rowData.checked? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case Accessory_Disclosure:
                aCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case Accessory_Favor:
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *image = [UIImage imageNamed:@"star02"];
                [button setBackgroundImage:image forState:UIControlStateNormal];
                [button setBackgroundImage:image forState:UIControlStateHighlighted];
                button.frame = CGRectMake(0.0, 0.0, 24.0, 19.0);
                [button addTarget:self action:@selector(accessoryButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
                aCell.accessoryView = button;
                break;
            }
            case Accessory_Switch:
            {
                UISwitch *aView = [[UISwitch alloc] init];
                [aView addTarget:self action:@selector(switchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                aCell.accessoryView = aView;
                break;
            }
            case Accessory_Camera:
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(accessoryButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
                button.frame = CGRectMake(0.0, 0.0, 24.0, 19.0);
                aCell.accessoryView = button;
                break;
            }
            default:
                aCell.accessoryType = UITableViewCellAccessoryNone;
                break;
        }
    }
    
    return aCell;
}

- (void)reloadTableViewData
{
    NSMutableArray *sectionTitles = [NSMutableArray array];
    [sectionTitles addObject:[[A3DateCalcTableRowData alloc] initSeparatorWithText:@"" Height:36 AccessoryType:Accessory_None]];
    [sectionTitles addObject:[[A3DateCalcTableRowData alloc] initSeparatorWithText:@"" Height:36 AccessoryType:Accessory_None]];
    [sectionTitles addObject:[[A3DateCalcTableRowData alloc] initSeparatorWithText:NSLocalizedString(@"ADVANCED", @"ADVANCED") Height:56 AccessoryType:Accessory_ArrowDown]];
    self.sectionTitles = sectionTitles;
    
    
    NSMutableArray *sections = [NSMutableArray array];
    [sections addObject:@[
      [[A3DateCalcTableRowData alloc] initCellWithText:@"Date Calculator 01" Detail:nil Height:44 AccessoryType:Accessory_Favor],
      [[A3DateCalcTableRowData alloc] initCellWithText:@"Photo" Detail:nil Height:44 AccessoryType:Accessory_Camera]
    ]];
    [sections addObject:@[
      [[A3DateCalcTableRowData alloc] initCellWithText:@"Lunar" Detail:nil Height:44 AccessoryType:Accessory_Switch],
      [[A3DateCalcTableRowData alloc] initCellWithText:@"All-day" Detail:nil Height:44 AccessoryType:Accessory_Switch],
      [[A3DateCalcTableRowData alloc] initCellWithText:@"Starts-Ends" Detail:nil Height:44 AccessoryType:Accessory_Switch],
      [[A3DateCalcTableRowData alloc] initCellWithText:@"Date" Detail:nil Height:44 AccessoryType:Accessory_TextField]
    ]];
    [sections addObject:@[
                          ]];
    self.sections = sections;
}
@end
